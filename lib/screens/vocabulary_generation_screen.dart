import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary_request.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/user_provider.dart';
import '../utils/string_extensions.dart';
import '../utils/app_utils.dart';
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
  
  bool _hasInitialized = false;

  bool _isMultiple = false;
  String _selectedLevel = 'A1';
  String _selectedLanguageToLearn = 'english';
  String _selectedNativeLanguage = 'vietnamese';

  // Content type controls
  bool _includeVocabulary = true;
  bool _includePhrasalVerbs = true;
  bool _includeIdioms = true;
  
  
  // Quantity controls
  int _vocabPerBatch = 10;
  int _phrasalVerbsPerBatch = 5;
  int _idiomsPerBatch = 3;
  int _delaySeconds = 2;
  bool _saveTopicList = true; // only used for multiple
  
  // UI state
  bool _showAdvancedOptions = false;

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final List<String> _languagesToLearn = ['english', 'spanish', 'french', 'german', 'italian', 'chinese', 'japanese', 'korean'];
  final List<String> _nativeLanguages = ['vietnamese', 'english', 'spanish', 'french', 'german'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
    });
  }

  void _initializeUser() async {
    if (_hasInitialized) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
    
    print('🔐 VocabGenScreen: Initializing user session...');
    print('🔐 VocabGenScreen: UserProvider logged in: ${userProvider.isLoggedIn}');
    print('🔐 VocabGenScreen: UserProvider has token: ${userProvider.sessionToken != null}');
    
    if (userProvider.currentUser != null && userProvider.sessionToken != null) {
      print('🔐 VocabGenScreen: Setting session token in VocabProvider WITH UserProvider for auto-refresh');
      vocabProvider.setSessionToken(
        userProvider.sessionToken!,
        userProvider: userProvider,  // ← Pass UserProvider for auto token refresh!
      );
      
      // Also ensure it's in SharedPreferences for VocabularyService
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_session_token', userProvider.sessionToken!);
        print('🔐 VocabGenScreen: Token saved to SharedPreferences');
      } catch (e) {
        print('🔐 VocabGenScreen: Failed to save token to SharedPreferences: $e');
      }
    } else {
      print('🔐 VocabGenScreen: WARNING - No user session found');
    }
    
    _hasInitialized = true;
  }

  @override
  void dispose() {
    _topicController.dispose();
    _multiTopicsController.dispose();
    _topicListNameController.dispose();
    super.dispose();
  }

  void _generateVocabulary() {
    // Validate that at least one content type is enabled
    if (!_includeVocabulary && !_includePhrasalVerbs && !_includeIdioms) {
      AppUtils.showWarningSnackBar(context, 'Please enable at least one content type (vocabulary, phrasal verbs, or idioms)');
      return;
    }

    if (!_isMultiple) {
      // Single topic path
      if (_formKey.currentState!.validate()) {
        final topic = _topicController.text.trim();
        
        // Show loading indicator
        AppUtils.showLoadingSnackBar(context, 'Generating vocabulary for "$topic"...');

        // Debug: Log form values before creating request
        print('🔍 Form Debug - Single Topic:');
        print('  - _includeVocabulary: $_includeVocabulary');
        print('  - _vocabPerBatch: $_vocabPerBatch');
        print('  - _includePhrasalVerbs: $_includePhrasalVerbs');
        print('  - _phrasalVerbsPerBatch: $_phrasalVerbsPerBatch');
        print('  - _includeIdioms: $_includeIdioms');
        print('  - _idiomsPerBatch: $_idiomsPerBatch');
        print('  - Total expected: ${(_includeVocabulary ? _vocabPerBatch : 0) + (_includePhrasalVerbs ? _phrasalVerbsPerBatch : 0) + (_includeIdioms ? _idiomsPerBatch : 0)}');

        final request = VocabularyRequest(
          topic: topic,
          level: _selectedLevel,
          languageToLearn: _selectedLanguageToLearn,
          learnersNativeLanguage: _selectedNativeLanguage,
          vocabPerBatch: _includeVocabulary ? _vocabPerBatch : 0,
          phrasalVerbsPerBatch: _includePhrasalVerbs ? _phrasalVerbsPerBatch : 0,
          idiomsPerBatch: _includeIdioms ? _idiomsPerBatch : 0,
          delaySeconds: _delaySeconds,
          saveTopicList: false, // single mode does not save topic list
        );

        // Debug: Log request values
        print('🔍 Request Debug - Single Topic:');
        print('  - vocabPerBatch: ${request.vocabPerBatch}');
        print('  - phrasalVerbsPerBatch: ${request.phrasalVerbsPerBatch}');
        print('  - idiomsPerBatch: ${request.idiomsPerBatch}');
        print('  - Total in request: ${request.vocabPerBatch + request.phrasalVerbsPerBatch + request.idiomsPerBatch}');

        context.read<VocabularyProvider>().generateVocabulary(request, context: context);

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
        AppUtils.showWarningSnackBar(context, 'Please enter at least one topic (comma-separated)');
        return;
      }

      // Show loading indicator
      AppUtils.showLoadingSnackBar(context, 'Generating vocabulary for ${topics.length} topics...');

      // Debug: Log form values before creating request
      print('🔍 Form Debug - Multiple Topics:');
      print('  - _includeVocabulary: $_includeVocabulary');
      print('  - _vocabPerBatch: $_vocabPerBatch');
      print('  - _includePhrasalVerbs: $_includePhrasalVerbs');
      print('  - _phrasalVerbsPerBatch: $_phrasalVerbsPerBatch');
      print('  - _includeIdioms: $_includeIdioms');
      print('  - _idiomsPerBatch: $_idiomsPerBatch');
      print('  - Total expected: ${(_includeVocabulary ? _vocabPerBatch : 0) + (_includePhrasalVerbs ? _phrasalVerbsPerBatch : 0) + (_includeIdioms ? _idiomsPerBatch : 0)}');

      final vocabPerBatch = _includeVocabulary ? _vocabPerBatch : 0;
      final phrasalVerbsPerBatch = _includePhrasalVerbs ? _phrasalVerbsPerBatch : 0;
      final idiomsPerBatch = _includeIdioms ? _idiomsPerBatch : 0;

      // Debug: Log request values
      print('🔍 Request Debug - Multiple Topics:');
      print('  - vocabPerBatch: $vocabPerBatch');
      print('  - phrasalVerbsPerBatch: $phrasalVerbsPerBatch');
      print('  - idiomsPerBatch: $idiomsPerBatch');
      print('  - Total in request: ${vocabPerBatch + phrasalVerbsPerBatch + idiomsPerBatch}');

      context.read<VocabularyProvider>().generateMultipleTopics(
            topics: topics,
            level: _selectedLevel,
            languageToLearn: _selectedLanguageToLearn,
            learnersNativeLanguage: _selectedNativeLanguage,
            vocabPerBatch: vocabPerBatch,
            phrasalVerbsPerBatch: phrasalVerbsPerBatch,
            idiomsPerBatch: idiomsPerBatch,
            delaySeconds: _delaySeconds,
            saveTopicList: _saveTopicList,
            topicListName: _topicListNameController.text.trim().isEmpty
                ? null
                : _topicListNameController.text.trim(),
            context: context,
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
                    .map((language) => DropdownMenuItem(
                      value: language, 
                      child: Text(
                        language.capitalize(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ))
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
                    .map((language) => DropdownMenuItem(
                      value: language, 
                      child: Text(
                        language.capitalize(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ))
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
                    .map((level) => DropdownMenuItem(
                      value: level, 
                      child: Text(
                        '$level - ${_getLevelDescription(level)}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedLevel = value!),
              ),
              const SizedBox(height: 24),

              // Advanced Options Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
                        child: Row(
                          children: [
                            Icon(
                              _showAdvancedOptions ? Icons.expand_less : Icons.expand_more,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Content Options',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _showAdvancedOptions ? 'Hide' : 'Show',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showAdvancedOptions) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Content Type Toggles
                        _buildContentTypeSection(),
                      ],
                    ],
                  ),
                ),
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

  Widget _buildContentTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Types to Generate',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Vocabulary Section
        _buildContentTypeControl(
          title: 'Vocabulary Words',
          isEnabled: _includeVocabulary,
          count: _vocabPerBatch,
          minCount: 1,
          maxCount: 50,
          onToggle: (value) => setState(() => _includeVocabulary = value),
          onCountChanged: (value) => setState(() => _vocabPerBatch = value),
          description: 'Common words and their definitions',
        ),
        
        const SizedBox(height: 16),
        
        // Phrasal Verbs Section
        _buildContentTypeControl(
          title: 'Phrasal Verbs',
          isEnabled: _includePhrasalVerbs,
          count: _phrasalVerbsPerBatch,
          minCount: 1,
          maxCount: 20,
          onToggle: (value) => setState(() => _includePhrasalVerbs = value),
          onCountChanged: (value) => setState(() => _phrasalVerbsPerBatch = value),
          description: 'Verb + preposition/adverb combinations',
        ),
        
        const SizedBox(height: 16),
        
        // Idioms Section
        _buildContentTypeControl(
          title: 'Idioms',
          isEnabled: _includeIdioms,
          count: _idiomsPerBatch,
          minCount: 1,
          maxCount: 15,
          onToggle: (value) => setState(() => _includeIdioms = value),
          onCountChanged: (value) => setState(() => _idiomsPerBatch = value),
          description: 'Expressions with meanings beyond literal words',
        ),
        
        const SizedBox(height: 20),
        
        // Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _buildSummaryText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentTypeControl({
    required String title,
    required bool isEnabled,
    required int count,
    required int minCount,
    required int maxCount,
    required Function(bool) onToggle,
    required Function(int) onCountChanged,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isEnabled 
            ? Theme.of(context).primaryColor.withOpacity(0.3)
            : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: isEnabled 
          ? Theme.of(context).primaryColor.withOpacity(0.05)
          : Colors.grey.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Count: ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: count.toDouble(),
                    min: minCount.toDouble(),
                    max: maxCount.toDouble(),
                    divisions: maxCount - minCount,
                    label: count.toString(),
                    onChanged: (value) => onCountChanged(value.round()),
                  ),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.centerRight,
                  child: Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _buildSummaryText() {
    final List<String> enabled = [];
    if (_includeVocabulary) enabled.add('$_vocabPerBatch vocabulary');
    if (_includePhrasalVerbs) enabled.add('$_phrasalVerbsPerBatch phrasal verbs');
    if (_includeIdioms) enabled.add('$_idiomsPerBatch idioms');
    
    if (enabled.isEmpty) {
      return 'Please enable at least one content type above';
    }
    
    return 'Will generate: ${enabled.join(', ')}';
  }
} 