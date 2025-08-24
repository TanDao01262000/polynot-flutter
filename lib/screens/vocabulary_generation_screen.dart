import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vocabulary_request.dart';
import '../providers/vocabulary_provider.dart';
import '../utils/string_extensions.dart';
import 'vocabulary_result_screen.dart';

class VocabularyGenerationScreen extends StatefulWidget {
  const VocabularyGenerationScreen({super.key});

  @override
  State<VocabularyGenerationScreen> createState() => _VocabularyGenerationScreenState();
}

class _VocabularyGenerationScreenState extends State<VocabularyGenerationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController(); // single
  final _multiTopicsController = TextEditingController(); // multiple (comma-separated)
  final _topicListNameController = TextEditingController(); // multiple (optional)

  bool _isMultiple = false;
  String _selectedLevel = 'A1';
  String _selectedLanguageToLearn = 'english';
  String _selectedNativeLanguage = 'vietnamese';

  // Internal defaults
  int _vocabPerBatch = 10;
  int _phrasalVerbsPerBatch = 5;
  int _idiomsPerBatch = 5;
  int _delaySeconds = 2;
  bool _saveTopicList = true; // only used for multiple

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final List<String> _languagesToLearn = ['english', 'spanish', 'french', 'german', 'italian', 'chinese', 'japanese', 'korean'];
  final List<String> _nativeLanguages = ['vietnamese', 'english', 'spanish', 'french', 'german'];

  @override
  void dispose() {
    _topicController.dispose();
    _multiTopicsController.dispose();
    _topicListNameController.dispose();
    super.dispose();
  }

  void _generateVocabulary() {
    if (!_isMultiple) {
      // Single topic path
      if (_formKey.currentState!.validate()) {
        final request = VocabularyRequest(
          topic: _topicController.text.trim(),
          level: _selectedLevel,
          languageToLearn: _selectedLanguageToLearn,
          learnersNativeLanguage: _selectedNativeLanguage,
          vocabPerBatch: _vocabPerBatch,
          phrasalVerbsPerBatch: _phrasalVerbsPerBatch,
          idiomsPerBatch: _idiomsPerBatch,
          delaySeconds: _delaySeconds,
          saveTopicList: false, // single mode does not save topic list
        );

        context.read<VocabularyProvider>().generateVocabulary(request);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VocabularyResultScreen()),
        );
      }
    } else {
      // Multiple topics path
      final raw = _multiTopicsController.text.trim();
      final topics = raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      if (topics.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter at least one topic (comma-separated)')),
        );
        return;
      }

      context.read<VocabularyProvider>().generateMultipleTopics(
            topics: topics,
            level: _selectedLevel,
            languageToLearn: _selectedLanguageToLearn,
            learnersNativeLanguage: _selectedNativeLanguage,
            vocabPerBatch: _vocabPerBatch,
            phrasalVerbsPerBatch: _phrasalVerbsPerBatch,
            idiomsPerBatch: _idiomsPerBatch,
            delaySeconds: _delaySeconds,
            saveTopicList: _saveTopicList,
            topicListName: _topicListNameController.text.trim().isEmpty
                ? null
                : _topicListNameController.text.trim(),
          );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VocabularyResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Vocabulary'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode selector
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Single topic'),
                    selected: !_isMultiple,
                    onSelected: (v) {
                      if (v) setState(() => _isMultiple = false);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Multiple topics'),
                    selected: _isMultiple,
                    onSelected: (v) {
                      if (v) setState(() => _isMultiple = true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Topic inputs
              if (!_isMultiple) ...[
                Text(
                  'Topic or Theme',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _topicController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Technology, Travel, Food...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a topic';
                    }
                    return null;
                  },
                ),
              ] else ...[
                Text(
                  'Topics (comma-separated)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _multiTopicsController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Technology, Travel, Food',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Topic List Name (Optional)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _topicListNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Spring Semester Set',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Save to topic list for future reference'),
                  value: _saveTopicList,
                  onChanged: (value) {
                    setState(() => _saveTopicList = value);
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Language to Learn
              Text(
                'Language to Learn',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLanguageToLearn,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                items: _languagesToLearn
                    .map((language) => DropdownMenuItem(value: language, child: Text(language.capitalize())))
                    .toList(),
                onChanged: (value) => setState(() => _selectedLanguageToLearn = value!),
              ),
              const SizedBox(height: 16),

              // Native Language
              Text(
                'Native Language',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedNativeLanguage,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                items: _nativeLanguages
                    .map((language) => DropdownMenuItem(value: language, child: Text(language.capitalize())))
                    .toList(),
                onChanged: (value) => setState(() => _selectedNativeLanguage = value!),
              ),
              const SizedBox(height: 24),

              // Level Selection
              Text(
                'CEFR Level',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                items: _levels
                    .map((level) => DropdownMenuItem(value: level, child: Text('$level - ${_getLevelDescription(level)}')))
                    .toList(),
                onChanged: (value) => setState(() => _selectedLevel = value!),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _generateVocabulary,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _isMultiple ? 'Generate (Multiple)' : 'Generate (Single)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  String _getLevelDescription(String level) {
    switch (level) {
      case 'A1':
        return 'Beginner';
      case 'A2':
        return 'Elementary';
      case 'B1':
        return 'Intermediate';
      case 'B2':
        return 'Upper Intermediate';
      case 'C1':
        return 'Advanced';
      case 'C2':
        return 'Mastery';
      default:
        return '';
    }
  }
} 