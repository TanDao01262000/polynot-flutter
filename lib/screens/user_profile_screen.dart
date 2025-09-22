import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/tts_provider.dart';
import '../providers/user_plan_provider.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/user_plan_widget.dart';
import 'voice_cloning_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user profile and voice profiles when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      final userPlanProvider = Provider.of<UserPlanProvider>(context, listen: false);
      
      if (userProvider.currentUser != null) {
        userProvider.getUserProfile(userProvider.currentUser!.userName);
      }
      
        // Load voice profiles if user is authenticated
        if (userProvider.isLoggedIn) {
          // Set the current user ID for TTS provider if not already set
          if (ttsProvider.currentUserId == null && userProvider.sessionToken != null) {
            ttsProvider.setCurrentUserId(userProvider.sessionToken!);
          }
          // Load voice profiles and selected voice
          ttsProvider.loadVoiceProfiles();
          ttsProvider.loadSelectedVoiceId();
          
          // Load user plan information
          if (userPlanProvider.currentUserId == null && userProvider.sessionToken != null) {
            userPlanProvider.setCurrentUserId(userProvider.sessionToken!);
          }
          userPlanProvider.loadUserPlan();
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserProfileEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<UserProvider, VocabularyProvider>(
        builder: (context, userProvider, vocabProvider, child) {
          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (userProvider.currentUser == null) {
            return const Center(
              child: Text('No user logged in'),
            );
          }

          final user = userProvider.currentUser!;
          final statistics = userProvider.userStatistics;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          user.firstName?.isNotEmpty == true 
                              ? user.firstName![0].toUpperCase()
                              : user.userName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.firstName?.isNotEmpty == true 
                            ? '${user.firstName} ${user.lastName ?? ''}'
                            : user.userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.firstName?.isNotEmpty == true)
                        Text(
                          '@${user.userName}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // User Information Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Email', user.email),
                        _buildInfoRow('Language Level', 
                            '${user.userLevel} - ${UserService.getUserLevelDisplayName(user.userLevel)}'),
                        _buildInfoRow('Target Language', user.targetLanguageString),
                        _buildInfoRow('Member Since', 
                            '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User Plan Card
                const UserPlanWidget(),
                const SizedBox(height: 24),

                // Statistics Card
                if (statistics != null) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Learning Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                                                     Row(
                             children: [
                               Expanded(
                                 child: _buildStatCard(
                                   'Conversations',
                                   statistics.totalConversations.toString(),
                                   Icons.chat_bubble_outline,
                                   Colors.blue,
                                 ),
                               ),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: _buildStatCard(
                                   'Messages',
                                   statistics.totalMessages.toString(),
                                   Icons.message_outlined,
                                   Colors.green,
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 12),
                           Row(
                             children: [
                               Expanded(
                                 child: _buildStatCard(
                                   'Streak Days',
                                   statistics.streakDays.toString(),
                                   Icons.local_fire_department,
                                   Colors.orange,
                                 ),
                               ),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: _buildStatCard(
                                   'Vocabulary',
                                   vocabProvider.vocabularyListItems.length.toString(),
                                   Icons.book_outlined,
                                   Colors.indigo,
                                 ),
                               ),
                             ],
                           ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Actions Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.blue),
                          title: const Text('Edit Profile'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const UserProfileEditScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.school, color: Colors.green),
                          title: const Text('Change Language Level'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showLevelChangeDialog(context, userProvider, user.userName);
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.record_voice_over, color: Colors.purple),
                          title: const Text('Voice Settings'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showVoiceSelectionDialog(context);
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Logout'),
                          onTap: () {
                            _showLogoutDialog(context, userProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showLevelChangeDialog(BuildContext context, UserProvider userProvider, String userName) {
    String selectedLevel = userProvider.currentUser?.userLevel ?? 'A1';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Language Level'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select your current language proficiency level:'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedLevel,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Language Level',
                    ),
                    items: userProvider.getValidUserLevels().map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text('$level - ${UserService.getUserLevelDisplayName(level)}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedLevel = value;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await userProvider.updateUserLevel(userName, selectedLevel);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language level updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showVoiceSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer2<TTSProvider, UserPlanProvider>(
          builder: (context, ttsProvider, userPlanProvider, child) {
            return AlertDialog(
              title: const Text('Voice Settings'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select your preferred voice for pronunciation:'),
                    const SizedBox(height: 16),
                    if (ttsProvider.isLoading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Loading voice profiles...'),
                    ] else ...[
                      // Default voice option
                      RadioListTile<String?>(
                        title: const Text('Default Voice'),
                        subtitle: const Text('System default voice'),
                        value: null,
                        groupValue: ttsProvider.selectedVoiceId,
                        onChanged: (value) async {
                          await ttsProvider.setSelectedVoiceId(value);
                        },
                      ),
                      // Custom voice profiles (Premium only)
                      const Divider(),
                      Row(
                        children: [
                          const Text(
                            'Custom Voices',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: userPlanProvider.canUseCustomVoices ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              userPlanProvider.canUseCustomVoices ? 'PREMIUM' : 'PREMIUM ONLY',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      if (userPlanProvider.canUseCustomVoices) ...[
                        // Show custom voices for premium users
                        if (ttsProvider.voiceProfiles.isNotEmpty) ...[
                          ...ttsProvider.voiceProfiles.map((profile) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: RadioListTile<String?>(
                                title: Text(profile.voiceName),
                                subtitle: Text('${profile.provider} - ${profile.voiceId}'),
                                value: profile.voiceId,
                                groupValue: ttsProvider.selectedVoiceId,
                                onChanged: (value) async {
                                  await ttsProvider.setSelectedVoiceId(value);
                                },
                                secondary: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      final confirmed = await _showDeleteConfirmation(context, profile.voiceName);
                                      if (confirmed && mounted) {
                                        final success = await ttsProvider.deleteVoiceProfile(profile.id);
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Voice "${profile.voiceName}" deleted successfully'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed to delete voice: ${ttsProvider.error ?? "Unknown error"}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete Voice'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ] else ...[
                          const SizedBox(height: 8),
                          Text(
                            'No custom voices available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ] else ...[
                        // Show premium upgrade message for non-premium users
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.lock,
                                color: Colors.orange.shade600,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Custom Voices are Premium Features',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Upgrade to Premium to create and use custom voice clones',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Create new voice button (Premium only)
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: userPlanProvider.canUseVoiceCloning ? () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const VoiceCloningScreen(),
                              ),
                            );
                          } : () {
                            // Show premium upgrade message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Voice cloning is a Premium feature. Upgrade to create custom voices!'),
                                backgroundColor: Colors.orange,
                                action: SnackBarAction(
                                  label: 'Learn More',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    // Could navigate to upgrade page here
                                  },
                                ),
                              ),
                            );
                          },
                          icon: Icon(userPlanProvider.canUseVoiceCloning ? Icons.add : Icons.lock),
                          label: Text(userPlanProvider.canUseVoiceCloning 
                            ? 'Create New Voice Clone' 
                            : 'Create New Voice Clone (Premium Only)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: userPlanProvider.canUseVoiceCloning ? Colors.purple : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String voiceName) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Voice'),
          content: Text('Are you sure you want to delete the voice "$voiceName"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await userProvider.logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class UserProfileEditScreen extends StatefulWidget {
  const UserProfileEditScreen({super.key});

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  String _selectedTargetLanguage = 'English';
  String _selectedUserLevel = 'A1';
  bool _isLoading = false;
  
  // Available target languages
  final List<String> _targetLanguages = [
    'English',
    'Spanish', 
    'French',
    'German',
    'Italian',
    'Chinese',
    'Japanese',
    'Korean'
  ];

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeControllers();
      }
    });
  }

  void _initializeControllers() {
    try {
      // Dispose existing controllers first to prevent memory leaks
      _firstNameController?.dispose();
      _lastNameController?.dispose();
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;
      
      _firstNameController = TextEditingController(text: user?.firstName ?? '');
      _lastNameController = TextEditingController(text: user?.lastName ?? '');
      _selectedTargetLanguage = user?.targetLanguage ?? 'English';
      _selectedUserLevel = user?.userLevel ?? 'A1';
    } catch (e) {
      // Fallback initialization if there's an error
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _selectedTargetLanguage = 'English';
      _selectedUserLevel = 'A1';
    }
  }

  @override
  void dispose() {
    _firstNameController?.dispose();
    _lastNameController?.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userName = userProvider.currentUser?.userName;
      
      if (userName == null) {
        throw Exception('No user logged in');
      }

      final request = UserProfileUpdateRequest(
        userLevel: _selectedUserLevel,
        targetLanguage: _selectedTargetLanguage,
        firstName: _firstNameController?.text.trim().isEmpty == true
            ? null 
            : _firstNameController?.text.trim(),
        lastName: _lastNameController?.text.trim().isEmpty == true
            ? null 
            : _lastNameController?.text.trim(),
      );

      // Debug: Print the actual values being sent
      print('=== PROFILE UPDATE DEBUG ===');
      print('Selected User Level: $_selectedUserLevel');
      print('Selected Target Language: $_selectedTargetLanguage');
      print('First Name Controller Text: "${_firstNameController?.text}"');
      print('Last Name Controller Text: "${_lastNameController?.text}"');
      print('Request User Level: ${request.userLevel}');
      print('Request Target Language: ${request.targetLanguage}');
      print('Request First Name: ${request.firstName}');
      print('Request Last Name: ${request.lastName}');

      // Check if there are any actual changes to update
      final hasChanges = request.userLevel != null || 
                        request.targetLanguage != null || 
                        request.firstName != null || 
                        request.lastName != null;
      
      print('Has Changes: $hasChanges');
      print('========================');

      if (!hasChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No changes to update'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final success = await userProvider.updateUserProfile(userName, request);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Ensure controllers are initialized
          if (_firstNameController == null || _lastNameController == null) {
            // Use a post-frame callback to avoid build-time state changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _initializeControllers();
                setState(() {}); // Trigger rebuild with initialized controllers
              }
            });
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // First Name field
                  TextFormField(
                    controller: _firstNameController ?? TextEditingController(),
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      hintText: 'Enter your first name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Last Name field
                  TextFormField(
                    controller: _lastNameController ?? TextEditingController(),
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      hintText: 'Enter your last name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Target Language dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedTargetLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Target Language',
                      prefixIcon: Icon(Icons.language),
                      border: OutlineInputBorder(),
                    ),
                    items: _targetLanguages.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTargetLanguage = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Target language is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // User Level dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedUserLevel,
                    decoration: const InputDecoration(
                      labelText: 'Language Level',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                    items: userProvider.getValidUserLevels().map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text('$level - ${UserService.getUserLevelDisplayName(level)}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedUserLevel = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading || userProvider.isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading || userProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Update Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error message
                  if (userProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        userProvider.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
