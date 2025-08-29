import 'package:flutter/foundation.dart';
import '../models/vocabulary_item.dart';
import '../models/vocabulary_request.dart';
import '../models/generate_response.dart';
import '../models/vocabulary_category.dart';
import '../services/vocabulary_service.dart';

class VocabularyProvider extends ChangeNotifier {
  List<VocabularyItem> _vocabularyItems = [];
  List<VocabularyItem> _vocabularyListItems = [];
  List<VocabularyPersonalList> _personalLists = [];
  bool _isLoading = false;
  bool _isLoadingList = false;
  String? _error;
  VocabularyRequest? _currentRequest;
  GenerateResponse? _lastResponse;
  VocabularyListResponse? _lastListResponse;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentUserId;

  // Getters
  List<VocabularyItem> get vocabularyItems => _vocabularyItems;
  List<VocabularyItem> get vocabularyListItems => _vocabularyListItems;
  List<VocabularyPersonalList> get personalLists => _personalLists;
  bool get isLoading => _isLoading;
  bool get isLoadingList => _isLoadingList;
  String? get error => _error;
  VocabularyRequest? get currentRequest => _currentRequest;
  GenerateResponse? get lastResponse => _lastResponse;
  VocabularyListResponse? get lastListResponse => _lastListResponse;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  String? get currentUserId => _currentUserId;

  // Set current user ID for authenticated requests
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  // Clear current user ID
  void clearCurrentUserId() {
    _currentUserId = null;
  }

  // Get vocabulary list with pagination and filtering
  Future<void> getVocabularyList(VocabularyListRequest request) async {
    if (_isLoadingList) return;

    _isLoadingList = true;
    _error = null;
    notifyListeners();

    try {
      final response = await VocabularyService.getVocabularyList(
        request,
        userUuid: _currentUserId,
      );
      
      _lastListResponse = response;
      
      if (request.page == 1) {
        // Reset list for first page
        _vocabularyListItems = [];
      }
      
      // Convert response data to VocabularyItem objects
      final newItems = response.vocabularies.map((item) {
        if (item is Map<String, dynamic>) {
          return VocabularyItem.fromJson(item);
        }
        return null;
      }).whereType<VocabularyItem>().toList();
      
      _vocabularyListItems.addAll(newItems);
      _currentPage = response.page;
      _hasMore = response.hasMore;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _lastListResponse = null;
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  // Load more vocabulary items
  Future<void> loadMoreVocabulary(VocabularyListRequest baseRequest) async {
    if (!_hasMore || _isLoadingList) return;

    final nextPageRequest = VocabularyListRequest(
      page: _currentPage + 1,
      limit: baseRequest.limit,
      showFavoritesOnly: baseRequest.showFavoritesOnly,
      showHidden: baseRequest.showHidden,
      topicName: baseRequest.topicName,
      categoryName: baseRequest.categoryName,
      level: baseRequest.level,
      searchTerm: baseRequest.searchTerm,
    );

    await getVocabularyList(nextPageRequest);
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String vocabEntryId) async {
    if (_currentUserId == null) return false;

    try {
      final success = await VocabularyService.toggleFavorite(vocabEntryId, _currentUserId!);
      if (success) {
        // Update local state
        _updateVocabularyItem(vocabEntryId, (item) => item.copyWith(isFavorite: !item.isFavorite));
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Hide vocabulary temporarily
  Future<bool> hideVocabulary(String vocabEntryId, {DateTime? hiddenUntil}) async {
    if (_currentUserId == null) return false;

    try {
      final success = await VocabularyService.hideVocabulary(vocabEntryId, _currentUserId!, hiddenUntil: hiddenUntil);
      if (success) {
        // Update local state
        _updateVocabularyItem(vocabEntryId, (item) => item.copyWith(
          isHidden: !item.isHidden,
          hiddenUntil: hiddenUntil,
        ));
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Add personal notes
  Future<bool> addNote(String vocabEntryId, String note) async {
    if (_currentUserId == null) return false;

    try {
      final success = await VocabularyService.addNote(vocabEntryId, _currentUserId!, note);
      if (success) {
        // Update local state
        _updateVocabularyItem(vocabEntryId, (item) => item.copyWith(personalNotes: note));
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Rate difficulty
  Future<bool> rateDifficulty(String vocabEntryId, int rating) async {
    if (_currentUserId == null) return false;

    try {
      final success = await VocabularyService.rateDifficulty(vocabEntryId, _currentUserId!, rating);
      if (success) {
        // Update local state
        _updateVocabularyItem(vocabEntryId, (item) => item.copyWith(difficultyRating: rating));
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }



  // Mark as reviewed
  Future<bool> markAsReviewed(String vocabEntryId) async {
    if (_currentUserId == null) return false;

    try {
      final success = await VocabularyService.markAsReviewed(vocabEntryId, _currentUserId!);
      if (success) {
        // Update local state
        _updateVocabularyItem(vocabEntryId, (item) => item.copyWith(
          lastReviewed: DateTime.now(),
          reviewCount: item.reviewCount + 1,
        ));
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Create vocabulary list
  Future<VocabularyPersonalList?> createVocabularyList(String name, String description) async {
    if (_currentUserId == null) return null;

    try {
      final request = CreateVocabularyListRequest(name: name, description: description);
      final newList = await VocabularyService.createVocabularyList(request, _currentUserId!);
      if (newList != null) {
        _personalLists.add(newList);
        notifyListeners();
      }
      return newList;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Get user's vocabulary lists
  Future<void> getVocabularyLists() async {
    if (_currentUserId == null) return;

    try {
      _isLoadingList = true;
      notifyListeners();

      final lists = await VocabularyService.getVocabularyLists(_currentUserId!);
      _personalLists = lists;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  // Add vocabulary to list
  Future<bool> addToVocabularyList(String listId, String vocabEntryId) async {
    if (_currentUserId == null) return false;

    try {
      final success = await VocabularyService.addToVocabularyList(listId, vocabEntryId, _currentUserId!);
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Remove vocabulary from list
  Future<bool> removeFromVocabularyList(String listId, String vocabEntryId) async {
    if (_currentUserId == null) return false;

    try {
      final success = await VocabularyService.removeFromVocabularyList(listId, vocabEntryId, _currentUserId!);
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Helper method to update vocabulary item in both lists
  void _updateVocabularyItem(String vocabEntryId, VocabularyItem Function(VocabularyItem) updateFn) {
    // Update in generated items list
    final generatedIndex = _vocabularyItems.indexWhere((item) => item.id == vocabEntryId);
    if (generatedIndex != -1) {
      _vocabularyItems[generatedIndex] = updateFn(_vocabularyItems[generatedIndex]);
    }

    // Update in list items
    final listIndex = _vocabularyListItems.indexWhere((item) => item.id == vocabEntryId);
    if (listIndex != -1) {
      _vocabularyListItems[listIndex] = updateFn(_vocabularyListItems[listIndex]);
    }
  }

  // Clear vocabulary list
  void clearVocabularyList() {
    _vocabularyListItems.clear();
    _currentPage = 1;
    _hasMore = true;
    _lastListResponse = null;
    notifyListeners();
  }

  // Clear personal lists
  void clearPersonalLists() {
    _personalLists.clear();
    notifyListeners();
  }

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