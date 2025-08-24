import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  String _selectedUserLevel = 'A1';
  String _selectedTargetLanguage = 'English';
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
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final request = UserRegistrationRequest(
        userName: _userNameController.text.trim(),
        email: _emailController.text.trim(),
        userLevel: _selectedUserLevel,
        targetLanguage: _selectedTargetLanguage,
        firstName: _firstNameController.text.trim().isEmpty 
            ? null 
            : _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty 
            ? null 
            : _lastNameController.text.trim(),
      );

      final success = await userProvider.registerUser(request);
      
      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please check your email to confirm your account.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back or to login screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
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
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Text(
                    'Join PolyNot',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your account to start learning languages with AI partners',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Username field
                  TextFormField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: 'Username *',
                      hintText: 'Enter your username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      hintText: 'Enter your email address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,}$').hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // First Name field
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name (Optional)',
                      hintText: 'Enter your first name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Last Name field
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name (Optional)',
                      hintText: 'Enter your last name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Target Language field
                  DropdownButtonFormField<String>(
                    value: _selectedTargetLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Target Language *',
                      hintText: 'e.g., English, Spanish, French',
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
                  ),
                  const SizedBox(height: 16),

                  // User Level dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedUserLevel,
                    decoration: const InputDecoration(
                      labelText: 'Language Level *',
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
                  const SizedBox(height: 24),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Account Setup',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Please use a real email address (Gmail, Yahoo, Outlook, etc.)\n'
                          '• Password will be set to TestPassword123!\n'
                          '• You will receive an email confirmation link\n'
                          '• Please confirm your email before logging in',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading || userProvider.isLoading ? null : _registerUser,
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
                              'Create Account',
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
