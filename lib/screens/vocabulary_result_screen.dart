import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/vocabulary_item_card.dart';
import '../widgets/vocabulary_interaction_card.dart';
import '../utils/string_extensions.dart';

class VocabularyResultScreen extends StatefulWidget {
  const VocabularyResultScreen({super.key});

  @override
  State<VocabularyResultScreen> createState() => _VocabularyResultScreenState();
}

class _VocabularyResultScreenState extends State<VocabularyResultScreen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
    });
  }

  void _initializeUser() {
    if (_hasInitialized) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
    
    if (userProvider.currentUser != null) {
      vocabProvider.setCurrentUserId(userProvider.currentUser!.id);
    }
    
    _hasInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Vocabulary'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<VocabularyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating vocabulary...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (provider.vocabularyItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No vocabulary generated',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try generating some vocabulary first',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header with request info (category removed)
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.currentRequest != null) ...[
                      Text(
                        'Topic: ${provider.currentRequest!.topic}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level: ${provider.currentRequest!.level}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Language: ${provider.currentRequest!.languageToLearn.capitalize()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (provider.lastResponse != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Generated ${provider.lastResponse!.totalGenerated} items',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Vocabulary list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.vocabularyItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.vocabularyItems[index];
                    return Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        if (userProvider.currentUser != null) {
                          // Use interactive card for logged-in users
                          return VocabularyInteractionCard(
                            item: item,
                            onFavorite: () => provider.toggleFavorite(item.id),
                            onHide: () => provider.hideVocabulary(item.id),
                            onRate: (rating) => provider.rateDifficulty(item.id, rating),
                            onReview: () => provider.markAsReviewed(item.id),
                            onAddNote: (note) => provider.addNote(item.id, note),
                            onAddToList: (listId) => provider.addToVocabularyList(listId, item.id),
                            personalLists: provider.personalLists,
                          );
                        } else {
                          // Use basic card for non-logged-in users
                          return VocabularyItemCard(
                            item: item,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.word} - ${item.definition}'),
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<VocabularyProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed: () {
              provider.clearVocabulary();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Generate More'),
          );
        },
      ),
    );
  }
} 