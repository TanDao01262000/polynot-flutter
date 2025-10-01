import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/vocabulary_item_card.dart';
import '../widgets/vocabulary_generation_card.dart';
import '../utils/string_extensions.dart';
import '../utils/app_utils.dart';

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
    
    if (userProvider.currentUser != null && userProvider.sessionToken != null) {
      vocabProvider.setSessionToken(
        userProvider.sessionToken!,
        userProvider: userProvider,  // ← Pass UserProvider for auto token refresh!
      );
    }
    
    _hasInitialized = true;
  }

  Future<bool> _saveItem(String vocabEntryId) async {
    print('_saveItem called with ID: $vocabEntryId');
    
    final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
    
    // Check if already saving
    if (vocabProvider.isSaving(vocabEntryId)) {
      print('Item $vocabEntryId is already being saved, skipping...');
      return false;
    }

    print('Starting save process for item: $vocabEntryId');
    final success = await vocabProvider.saveVocabularyEntry(vocabEntryId);
    print('Save result for item $vocabEntryId: $success');

    if (success) {
      AppUtils.showSuccessSnackBar(context, 'Vocabulary saved successfully!');
    } else {
      AppUtils.showErrorSnackBar(
        context, 
        vocabProvider.error ?? 'Failed to save vocabulary',
        onRetry: () => _saveItem(vocabEntryId),
      );
    }
    
    return success;
  }

  Future<void> _saveAllItems() async {
    final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
    final items = vocabProvider.vocabularyItems;

    int savedCount = 0;
    int failedCount = 0;

    for (final item in items) {
      if (!item.isSaved) { // Only save items that haven't been saved yet
        final success = await vocabProvider.saveVocabularyEntry(item.id);
        if (success) {
          savedCount++;
        } else {
          failedCount++;
        }
      }
    }

    if (savedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved $savedCount items successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    if (failedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save $failedCount items'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Vocabulary'),
        centerTitle: true,
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.currentUser != null) {
                return Consumer<VocabularyProvider>(
                  builder: (context, vocabProvider, child) {
                    if (vocabProvider.vocabularyItems.isNotEmpty) {
                      return PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          switch (value) {
                            case 'save_all':
                              _saveAllItems();
                              break;
                            case 'share':
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Share feature coming soon!')),
                              );
                              break;
                          }
                        },
                                                 itemBuilder: (context) => [
                           PopupMenuItem(
                             value: 'save_all',
                             child: Row(
                               children: [
                                 Icon(Icons.save),
                                 SizedBox(width: 8),
                                 Text('Save All Items'),
                               ],
                             ),
                           ),
                          const PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share),
                                SizedBox(width: 8),
                                Text('Share'),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }
              return const SizedBox.shrink();
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
              // Header with request info and generation stats
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level: ${provider.currentRequest!.level}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Language: ${provider.currentRequest!.languageToLearn.capitalize()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

              // Quick access to vocabulary list
              if (context.read<UserProvider>().currentUser != null) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/vocabulary-list');
                    },
                    icon: const Icon(Icons.list_alt, size: 20),
                    label: const Text(
                      'View My Vocabulary List',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    icon: const Icon(Icons.login, size: 20),
                    label: const Text(
                      'Login to Save & View Vocabulary',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade50,
                      foregroundColor: Colors.orange.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.orange.shade200),
                      ),
                    ),
                  ),
                ),
              ],

              // Vocabulary list
              Expanded(
                child: Consumer2<UserProvider, VocabularyProvider>(
                  builder: (context, userProvider, vocabProvider, child) {
                    if (userProvider.currentUser != null) {
                      // Use generation cards for logged-in users with save functionality
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vocabProvider.vocabularyItems.length,
                        itemBuilder: (context, index) {
                          final item = vocabProvider.vocabularyItems[index];
                          return VocabularyGenerationCard(
                            key: ValueKey('vocab_gen_${item.id}_${index}'),
                            item: item,
                            onSave: (String itemId) async {
                              print('Save button clicked for item: ${item.word} (ID: $itemId)');
                              return await _saveItem(itemId);
                            },
                            isSaving: vocabProvider.isSaving(item.id),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.word} - ${item.definition}'),
                                ),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      // Use basic cards for non-logged-in users
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vocabProvider.vocabularyItems.length,
                        itemBuilder: (context, index) {
                          final item = vocabProvider.vocabularyItems[index];
                          return VocabularyItemCard(
                            key: ValueKey('vocab_basic_$index'),
                            item: item,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.word} - ${item.definition}'),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
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
            onPressed: () async {
              // Show loading indicator
              AppUtils.showLoadingSnackBar(context, 'Generating more vocabulary...');
              
              // Regenerate with same parameters
              await provider.regenerateVocabulary();
              
              // Show success message if no error
              if (provider.error == null) {
                AppUtils.showSuccessSnackBar(context, 'New vocabulary generated!');
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Generate More'),
          );
        },
      ),
    );
  }
} 