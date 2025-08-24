import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/main_option_card.dart';
import '../providers/user_provider.dart';
import './partner_selection_screen.dart';
import './vocabulary_generation_screen.dart';
import './user_registration_screen.dart';
import './user_login_screen.dart';
import './user_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polynot'),
        centerTitle: true,
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoggedIn) {
                return IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                  },
                );
              } else {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.login),
                  onSelected: (value) {
                    if (value == 'register') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserRegistrationScreen(),
                        ),
                      );
                    } else if (value == 'login') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserLoginScreen(),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'register',
                      child: Row(
                        children: [
                          Icon(Icons.person_add),
                          SizedBox(width: 8),
                          Text('Register'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'login',
                      child: Row(
                        children: [
                          Icon(Icons.login),
                          SizedBox(width: 8),
                          Text('Login'),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome section
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Column(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userProvider.isLoggedIn 
                          ? 'Welcome back, ${userProvider.currentUser?.firstName ?? userProvider.currentUser?.userName ?? 'User'}!'
                          : 'Welcome to Polynot',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userProvider.isLoggedIn
                          ? 'Ready to continue your language learning journey?'
                          : 'Choose what you\'d like to do today',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (userProvider.isLoggedIn) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Level: ${userProvider.currentUser?.userLevel} - ${userProvider.getUserLevelDisplayName()}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 48),
            
            // Main options
            MainOptionCard(
              text: 'Chat Partner',
              subtitle: 'Have conversations with AI partners',
              icon: Icons.chat_bubble_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartnerSelectScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            MainOptionCard(
              text: 'Vocabulary Generator',
              subtitle: 'Generate vocabulary lists, phrasal verbs, and idioms',
              icon: Icons.book_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VocabularyGenerationScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 