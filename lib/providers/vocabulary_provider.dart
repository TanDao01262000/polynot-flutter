import 'package:flutter/foundation.dart';
import '../models/vocabulary_item.dart';
import '../models/vocabulary_request.dart';
import '../models/generate_response.dart';
import '../services/vocabulary_service.dart';

class VocabularyProvider extends ChangeNotifier {
  List<VocabularyItem> _vocabularyItems = [];
  bool _isLoading = false;
  String? _error;
  VocabularyRequest? _currentRequest;
  GenerateResponse? _lastResponse;

  List<VocabularyItem> get vocabularyItems => _vocabularyItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  VocabularyRequest? get currentRequest => _currentRequest;
  GenerateResponse? get lastResponse => _lastResponse;

  Future<void> generateVocabulary(VocabularyRequest request) async {
    _isLoading = true;
    _error = null;
    _currentRequest = request;
    notifyListeners();

    try {
      final response = await VocabularyService.generateSingleTopic(request);
      _lastResponse = response;
      _vocabularyItems = response.generatedVocabulary;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _vocabularyItems = [];
      _lastResponse = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateMultipleTopics({
    required List<String> topics,
    required String level,
    required String languageToLearn,
    required String learnersNativeLanguage,
    int vocabPerBatch = 10,
    int phrasalVerbsPerBatch = 5,
    int idiomsPerBatch = 3,
    int delaySeconds = 2,
    bool saveTopicList = true,
    String? topicListName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await VocabularyService.generateMultipleTopics(
        topics: topics,
        level: level,
        languageToLearn: languageToLearn,
        learnersNativeLanguage: learnersNativeLanguage,
        vocabPerBatch: vocabPerBatch,
        phrasalVerbsPerBatch: phrasalVerbsPerBatch,
        idiomsPerBatch: idiomsPerBatch,
        delaySeconds: delaySeconds,
        saveTopicList: saveTopicList,
        topicListName: topicListName,
      );
      _lastResponse = response;
      _vocabularyItems = response.generatedVocabulary;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _vocabularyItems = [];
      _lastResponse = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateByCategory({
    required String category,
    required String level,
    required String languageToLearn,
    required String learnersNativeLanguage,
    int vocabPerBatch = 10,
    int phrasalVerbsPerBatch = 5,
    int idiomsPerBatch = 3,
    int delaySeconds = 2,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await VocabularyService.generateByCategory(
        category: category,
        level: level,
        languageToLearn: languageToLearn,
        learnersNativeLanguage: learnersNativeLanguage,
        vocabPerBatch: vocabPerBatch,
        phrasalVerbsPerBatch: phrasalVerbsPerBatch,
        idiomsPerBatch: idiomsPerBatch,
        delaySeconds: delaySeconds,
      );
      _lastResponse = response;
      _vocabularyItems = response.generatedVocabulary;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _vocabularyItems = [];
      _lastResponse = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearVocabulary() {
    _vocabularyItems = [];
    _error = null;
    _currentRequest = null;
    _lastResponse = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 