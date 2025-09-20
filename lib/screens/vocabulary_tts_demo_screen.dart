import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vocabulary_item.dart';
import '../providers/tts_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/vocabulary_card_widget.dart';
import '../widgets/tts_widgets.dart';

class VocabularyTTSDemoScreen extends StatefulWidget {
  const VocabularyTTSDemoScreen({super.key});

  @override
  State<VocabularyTTSDemoScreen> createState() => _VocabularyTTSDemoScreenState();
}

class _VocabularyTTSDemoScreenState extends State<VocabularyTTSDemoScreen> {
  late List<VocabularyItem> _demoVocabulary;

  @override
  void initState() {
    super.initState();
    _initializeDemoData();
  }

  void _initializeDemoData() {
    _demoVocabulary = [
      VocabularyItem(
        id: 'demo-1',
        word: 'Serendipity',
        definition: 'The occurrence and development of events by chance in a happy or beneficial way',
        translation: 'sự tình cờ may mắn',
        partOfSpeech: 'noun',
        example: 'Finding this book was pure serendipity.',
        exampleTranslation: 'Việc tìm thấy cuốn sách này là một sự tình cờ may mắn.',
        level: 'B2',
        topicId: 'demo-topic-1',
        targetLanguage: 'English',
        originalLanguage: 'Vietnamese',
        createdAt: DateTime.now(),
        isDuplicate: false,
        category: 'vocabulary',
      ),
      VocabularyItem(
        id: 'demo-2',
        word: 'Ubiquitous',
        definition: 'Present, appearing, or found everywhere',
        translation: 'phổ biến',
        partOfSpeech: 'adjective',
        example: 'Mobile phones have become ubiquitous in modern society.',
        exampleTranslation: 'Điện thoại di động đã trở nên phổ biến trong xã hội hiện đại.',
        level: 'B1',
        topicId: 'demo-topic-1',
        targetLanguage: 'English',
        originalLanguage: 'Vietnamese',
        createdAt: DateTime.now(),
        isDuplicate: false,
        category: 'vocabulary',
      ),
      VocabularyItem(
        id: 'demo-3',
        word: 'Look up to',
        definition: 'To admire and respect someone',
        translation: 'ngưỡng mộ',
        partOfSpeech: 'phrasal verb',
        example: 'I really look up to my older sister.',
        exampleTranslation: 'Tôi thực sự ngưỡng mộ chị gái của mình.',
        level: 'A2',
        topicId: 'demo-topic-1',
        targetLanguage: 'English',
        originalLanguage: 'Vietnamese',
        createdAt: DateTime.now(),
        isDuplicate: false,
        category: 'phrasal_verb',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<TTSProvider>(
            builder: (context, ttsProvider, child) {
              return IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showTTSInfo(context, ttsProvider),
              );
            },
          ),
        ],
      ),
      body: Consumer2<TTSProvider, UserProvider>(
        builder: (context, ttsProvider, userProvider, child) {
          // Set session token for TTS provider if user is logged in
          if (userProvider.currentUser != null && userProvider.sessionToken != null && ttsProvider.currentUserId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ttsProvider.setCurrentUserId(userProvider.sessionToken!);
            });
          }

          return Column(
            children: [
              // TTS Quota Display
              if (ttsProvider.quota != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TTSQuotaDisplay(showDetails: true),
                ),
              
              // Demo instructions
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.volume_up,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TTS Demo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the volume icons to generate and play pronunciation audio for vocabulary words. The TTS system supports multiple pronunciation speeds (normal, slow) and integrates with your vocabulary learning.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Vocabulary list
              Expanded(
                child: ListView.builder(
                  itemCount: _demoVocabulary.length,
                  itemBuilder: (context, index) {
                    final vocabulary = _demoVocabulary[index];
                    return VocabularyCardWidget(
                      vocabularyItem: vocabulary,
                      showTTS: true,
                      showActions: true,
                      onTap: () => _showVocabularyDetails(context, vocabulary),
                      onFavorite: () => _toggleFavorite(vocabulary),
                      onSave: () => _saveVocabulary(vocabulary),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTTSInfo(BuildContext context, TTSProvider ttsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('TTS Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: ${ttsProvider.currentUserId ?? 'Not set'}'),
            const SizedBox(height: 8),
            Text('Voice Profiles: ${ttsProvider.voiceProfiles.length}'),
            const SizedBox(height: 8),
            if (ttsProvider.subscription != null) ...[
              Text('Plan: ${ttsProvider.subscription!.plan}'),
              Text('Status: ${ttsProvider.subscription!.status}'),
            ],
            if (ttsProvider.quota != null) ...[
              const SizedBox(height: 8),
              Text('Characters Used: ${ttsProvider.quota!.charactersUsedThisMonth}'),
              Text('Characters Remaining: ${ttsProvider.quota!.charactersRemaining}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVocabularyDetails(BuildContext context, VocabularyItem vocabulary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vocabulary.word),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Definition: ${vocabulary.definition}'),
              const SizedBox(height: 8),
              Text('Translation: ${vocabulary.translation}'),
              const SizedBox(height: 8),
              Text('Part of Speech: ${vocabulary.partOfSpeech}'),
              const SizedBox(height: 8),
              Text('Level: ${vocabulary.level}'),
              const SizedBox(height: 8),
              Text('Category: ${vocabulary.category}'),
              if (vocabulary.example.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Example: ${vocabulary.example}'),
              ],
              if (vocabulary.exampleTranslation.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Example Translation: ${vocabulary.exampleTranslation}'),
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
      ),
    );
  }

  void _toggleFavorite(VocabularyItem vocabulary) {
    // In a real app, this would call the vocabulary service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vocabulary.isFavorite ? 'Removed from' : 'Added to'} favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveVocabulary(VocabularyItem vocabulary) {
    // In a real app, this would call the vocabulary service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vocabulary.isSaved ? 'Removed from' : 'Added to'} saved vocabulary'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
