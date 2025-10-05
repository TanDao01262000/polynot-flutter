import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/social_service.dart';
import '../models/social_models.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  UserPrivacySettings? _privacySettings;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        final settings = await SocialService.getPrivacySettings(
          userProvider.currentUser!.id,
        );
        
        setState(() {
          _privacySettings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading privacy settings: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _savePrivacySettings() async {
    if (_privacySettings == null) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        await SocialService.updatePrivacySettings(
          userProvider.currentUser!.id,
          _privacySettings!,
        );
        
        setState(() {
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Privacy settings updated successfully'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update privacy settings: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Privacy Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3498DB),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFE74C3C),
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading privacy settings',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadPrivacySettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_privacySettings == null) {
      return const Center(
        child: Text(
          'No privacy settings found',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7F8C8D),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Post Visibility',
            'Control who can see your posts',
            Icons.visibility,
          ),
          const SizedBox(height: 16),
          _buildShowPostsToLevelSetting(),
          const SizedBox(height: 24),
          
          _buildSectionHeader(
            'Content Sharing',
            'Manage what information you share',
            Icons.share,
          ),
          const SizedBox(height: 16),
          _buildToggleSetting(
            'Show Achievements',
            'Allow others to see your learning achievements',
            _privacySettings!.showAchievements,
            (value) => _updateSettings((settings) => settings.copyWith(showAchievements: value)),
          ),
          const SizedBox(height: 16),
          _buildToggleSetting(
            'Show Learning Progress',
            'Share your learning progress with the community',
            _privacySettings!.showLearningProgress,
            (value) => _updateSettings((settings) => settings.copyWith(showLearningProgress: value)),
          ),
          const SizedBox(height: 16),
          _buildToggleSetting(
            'Study Group Visibility',
            'Make yourself visible in study groups',
            _privacySettings!.studyGroupVisibility,
            (value) => _updateSettings((settings) => settings.copyWith(studyGroupVisibility: value)),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader(
            'Feed Preferences',
            'Control your personalized feed',
            Icons.tune,
          ),
          const SizedBox(height: 16),
          _buildToggleSetting(
            'Allow Level Filtering',
            'Let the system filter content based on your level',
            _privacySettings!.allowLevelFiltering,
            (value) => _updateSettings((settings) => settings.copyWith(allowLevelFiltering: value)),
          ),
          const SizedBox(height: 32),
          
          _buildSaveButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3498DB),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShowPostsToLevelSetting() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Show Posts To',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Control who can see your posts in their feed',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 16),
          ...['same', 'all', 'none'].map((option) {
            return RadioListTile<String>(
              value: option,
              groupValue: _privacySettings!.showPostsToLevel,
              onChanged: (value) => _updateSettings((settings) => settings.copyWith(showPostsToLevel: value)),
              title: Text(_getShowPostsToLevelLabel(option)),
              subtitle: Text(_getShowPostsToLevelDescription(option)),
              activeColor: const Color(0xFF3498DB),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3498DB),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _savePrivacySettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Saving...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text(
                'Save Privacy Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _updateSettings(UserPrivacySettings Function(UserPrivacySettings) updater) {
    setState(() {
      _privacySettings = updater(_privacySettings!);
    });
  }

  String _getShowPostsToLevelLabel(String option) {
    switch (option) {
      case 'same':
        return 'Same Level Only';
      case 'all':
        return 'All Users';
      case 'none':
        return 'Private';
      default:
        return option;
    }
  }

  String _getShowPostsToLevelDescription(String option) {
    switch (option) {
      case 'same':
        return 'Only users at your learning level can see your posts';
      case 'all':
        return 'All users in the community can see your posts';
      case 'none':
        return 'Your posts are private and not shown to others';
      default:
        return '';
    }
  }
}
