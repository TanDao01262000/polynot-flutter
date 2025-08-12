import 'package:flutter/material.dart';
import '../widgets/main_option_card.dart';
import './partner_selection_screen.dart';
import './vocabulary_generation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polynot'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome section
            Column(
              children: [
                Icon(
                  Icons.psychology,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to Polynot',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose what you\'d like to do today',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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