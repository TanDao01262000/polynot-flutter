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
  VocabularyListRequest? _lastListRequest;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentUserId;
  Set<String> _savingItems = {};

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
  Set<String> get savingItems => _savingItems;

  // Check if an item is currently being saved
  bool isSaving(String vocabEntryId) {
    return _savingItems.contains(vocabEntryId);
  }

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

    print('Provider: Loading vocabulary list with request: ${request.toJson()}');

    try {
      final response = await VocabularyService.getVocabularyList(
        request,
        userUuid: _currentUserId,
      );
      
      _lastListResponse = response;
      _lastListRequest = request;
      
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
      
      // Apply client-side search filtering if backend doesn't support it
      List<VocabularyItem> itemsToAdd;
      if (request.searchTerm != null && request.searchTerm!.isNotEmpty) {
        print('Provider: Applying client-side search filtering for: "${request.searchTerm}"');
        final searchTerm = request.searchTerm!.toLowerCase();
        final filteredItems = newItems.where((item) {
          return item.word.toLowerCase().contains(searchTerm) ||
                 item.definition.toLowerCase().contains(searchTerm) ||
                 item.translation.toLowerCase().contains(searchTerm) ||
                 item.example.toLowerCase().contains(searchTerm);
        }).toList();
        
        print('Provider: Filtered ${newItems.length} items to ${filteredItems.length} items');
        itemsToAdd = filteredItems;
      } else {
        itemsToAdd = newItems;
      }
      
      // Add items to the list
      _vocabularyListItems.addAll(itemsToAdd);
      
      // Sort the entire list: non-hidden items first, then alphabetically by word
      _vocabularyListItems.sort((a, b) {
        // First sort by hidden status (non-hidden items first)
        if (a.isHidden != b.isHidden) {
          return a.isHidden ? 1 : -1; // false (non-hidden) comes before true (hidden)
        }
        // Then sort alphabetically by word
        return a.word.toLowerCase().compareTo(b.word.toLowerCase());
      });
      
      print('Provider: Sorted vocabulary list (${_vocabularyListItems.length} items)');
      
      _currentPage = response.page;
      _hasMore = response.hasMore;
      _error = null;
      
      print('Provider: Loaded ${newItems.length} items. Total: ${_vocabularyListItems.length}');
      print('Provider: Response success: ${response.success}, message: ${response.message}');
    } catch (e) {
      _error = e.toString();
      _lastListResponse = null;
      print('Provider: Error loading vocabulary list: $e');
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
      print('Provider: Hiding vocabulary item: $vocabEntryId');
      final success = await VocabularyService.hideVocabulary(vocabEntryId, _currentUserId!, hiddenUntil: hiddenUntil);
      if (success) {
        print('Provider: Hide successful, updating local state...');
        
        // Find the item before update
        final beforeItem = _vocabularyListItems.firstWhere((item) => item.id == vocabEntryId);
        print('Provider: Before hide - isHidden: ${beforeItem.isHidden}');
        
        // Update local state immediately
        _updateVocabularyItem(vocabEntryId, (item) => item.copyWith(isHidden: true));
        
        // If we're not showing hidden items, remove the item from the current list
        if (_lastListRequest?.showHidden == false) {
          print('Provider: Removing hidden item from list since showHidden is false');
          _vocabularyListItems.removeWhere((item) => item.id == vocabEntryId);
          print('Provider: Item removed from list. New count: ${_vocabularyListItems.length}');
        } else {
          // If we're showing all items (hidden + non-hidden), move the hidden item to the bottom
          print('Provider: Moving hidden item to bottom of list (showing all items)');
          final item = _vocabularyListItems.firstWhere((item) => item.id == vocabEntryId);
          _vocabularyListItems.removeWhere((item) => item.id == vocabEntryId);
          _vocabularyListItems.add(item); // Add to the end (bottom)
          print('Provider: Item moved to bottom. New count: ${_vocabularyListItems.length}');
          
          // Find the item after update to verify the change
          final afterItem = _vocabularyListItems.firstWhere((item) => item.id == vocabEntryId);
          print('Provider: After hide - isHidden: ${afterItem.isHidden}');
        }
        
        notifyListeners();
        print('Provider: Local state updated after hiding');
      } else {
        print('Provider: Hide failed');
      }
      return success;
    } catch (e) {
      print('Provider: Error hiding vocabulary: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Unhide vocabulary
  Future<bool> unhideVocabulary(String vocabEntryId) async {
    if (_currentUserId == null) return false;

    try {
      print('Provider: Unhiding vocabulary item: $vocabEntryId');
      final success = await VocabularyService.unhideVocabulary(vocabEntryId, _currentUserId!);
      if (success) {
        print('Provider: Unhide successful, updating local state...');
        
        // Find the item before update
        final beforeItem = _vocabularyListItems.firstWhere((item) => item.id == vocabEntryId);
        print('Provider: Before unhide - isHidden: ${beforeItem.isHidden}');
        
        // Update local state immediately
        _updateVocabularyItem(vocabEntryId, (item) => item.copyWith(isHidden: false));
        
        // Find the item after update
        try {
          final afterItem = _vocabularyListItems.firstWhere((item) => item.id == vocabEntryId);
          print('Provider: After unhide - isHidden: ${afterItem.isHidden}');
          
          // If we're showing all items (hidden + non-hidden), move the unhidden item to the top
          if (_lastListRequest?.showHidden == true) {
            print('Provider: Moving unhidden item to top of list (showing all items)');
            final item = _vocabularyListItems.firstWhere((item) => item.id == vocabEntryId);
            _vocabularyListItems.removeWhere((item) => item.id == vocabEntryId);
            _vocabularyListItems.insert(0, item);
            print('Provider: Item moved to top. New count: ${_vocabularyListItems.length}');
          } else {
            // If we're only showing non-hidden items, the item should already be visible
            // and we don't need to do anything special
            print('Provider: Item already visible in non-hidden items list');
          }
        } catch (e) {
          print('Provider: Item not found in current list after unhide - this is expected if we removed it when hiding');
          
          // If we're not showing hidden items and the item was removed when hiding,
          // we need to reload the list to get the updated item back
          if (_lastListRequest?.showHidden == false) {
            print('Provider: Reloading list to get unhidden item back');
            await _reloadCurrentVocabularyList();
            print('Provider: List reloaded after unhide');
          }
        }
        
        notifyListeners();
        print('Provider: Local state updated after unhiding');
      } else {
        print('Provider: Unhide failed');
      }
      return success;
    } catch (e) {
      print('Provider: Error unhiding vocabulary: $e');
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

  // Unmark as reviewed
  Future<bool> unmarkAsReviewed(String vocabEntryId) async {
    if (_currentUserId == null) return false;

    try {
      print('Provider: Unmarking as reviewed: $vocabEntryId');
      final success = await VocabularyService.unmarkAsReviewed(vocabEntryId, _currentUserId!);
      if (success) {
        print('Provider: API call successful, updating local state...');
        
        // Find the item before update
        final beforeItem = _vocabularyListItems.firstWhere((item) => item.id == vocabEntryId);
        print('Provider: Before update - lastReviewed: ${beforeItem.lastReviewed}, reviewCount: ${beforeItem.reviewCount}');
        
        // Update local state - explicitly set lastReviewed to null
        _updateVocabularyItem(vocabEntryId, (item) {
          final newReviewCount = item.reviewCount > 0 ? item.reviewCount - 1 : 0;
          print('Provider: Creating new item with lastReviewed: null, reviewCount: $newReviewCount');
          return item.copyWithNull(
            lastReviewed: null,
            reviewCount: newReviewCount,
          );
        });
        
        // Find the item after update
        final afterItem = _vocabularyListItems.firstWhere((item) => item.id == vocabEntryId);
        print('Provider: After update - lastReviewed: ${afterItem.lastReviewed}, reviewCount: ${afterItem.reviewCount}');
        
        print('Provider: Calling notifyListeners()...');
        notifyListeners();
        print('Provider: Successfully unmarked as reviewed');
      } else {
        print('Provider: Failed to unmark as reviewed');
      }
      return success;
    } catch (e) {
      print('Provider: Error unmarking as reviewed: $e');
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

  // Get list contents
  Future<List<VocabularyItem>> getListContents(String listId) async {
    if (_currentUserId == null) return [];

    try {
      final items = await VocabularyService.getListContents(listId, _currentUserId!);
      return items;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
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

  // Save individual vocabulary entry
  Future<bool> saveVocabularyEntry(String vocabEntryId) async {
    print('Provider: Saving item with ID: $vocabEntryId');
    
    if (_currentUserId == null) {
      _error = 'User must be logged in to save vocabulary';
      notifyListeners();
      return false;
    }

    // Add to saving items set to prevent double-save
    if (_savingItems.contains(vocabEntryId)) {
      print('Provider: Item already being saved');
      return false;
    }

    _savingItems.add(vocabEntryId);
    notifyListeners();

    try {
      // Find the vocabulary item to get its data
      // If vocabEntryId is empty, try to find by word as fallback
      int itemIndex;
      if (vocabEntryId.isEmpty) {
        print('Provider: ID is empty, this should not happen with generated IDs');
        _savingItems.remove(vocabEntryId);
        notifyListeners();
        return false;
      } else {
        itemIndex = _vocabularyItems.indexWhere((item) => item.id == vocabEntryId);
      }
      
      print('Provider: Found item at index: $itemIndex');
      
      if (itemIndex == -1) {
        _error = 'Vocabulary item not found';
        _savingItems.remove(vocabEntryId);
        notifyListeners();
        return false;
      }

      final item = _vocabularyItems[itemIndex];
      print('Provider: Found item: ${item.word}, isSaved: ${item.isSaved}');
      
      // Don't save if already saved
      if (item.isSaved) {
        print('Provider: Item already saved');
        _savingItems.remove(vocabEntryId);
        notifyListeners();
        return true; // Already saved
      }
      
      final success = await VocabularyService.saveVocabularyEntry(vocabEntryId, _currentUserId!, item: item);
      print('Provider: API result: $success');
      
      if (success) {
        // Mark the item as saved
        _vocabularyItems[itemIndex] = item.copyWith(isSaved: true);
        _error = null;
        print('Provider: Marked as saved, calling notifyListeners');
      } else {
        _error = 'Failed to save vocabulary entry';
      }
      
      _savingItems.remove(vocabEntryId);
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      print('Provider: Error: $e');
      _savingItems.remove(vocabEntryId);
      notifyListeners();
      return false;
    }
  }



  // Helper method to update vocabulary item in both lists
  void _updateVocabularyItem(String vocabEntryId, VocabularyItem Function(VocabularyItem) updateFn) {
    print('Provider: _updateVocabularyItem called for: $vocabEntryId');
    
    // Update in generated items list
    final generatedIndex = _vocabularyItems.indexWhere((item) => item.id == vocabEntryId);
    if (generatedIndex != -1) {
      print('Provider: Updating generated item at index: $generatedIndex');
      _vocabularyItems[generatedIndex] = updateFn(_vocabularyItems[generatedIndex]);
    }

    // Update in list items
    final listIndex = _vocabularyListItems.indexWhere((item) => item.id == vocabEntryId);
    if (listIndex != -1) {
      print('Provider: Updating list item at index: $listIndex');
      final oldItem = _vocabularyListItems[listIndex];
      _vocabularyListItems[listIndex] = updateFn(_vocabularyListItems[listIndex]);
      final newItem = _vocabularyListItems[listIndex];
      print('Provider: Item updated - isHidden: ${oldItem.isHidden} -> ${newItem.isHidden}');
    } else {
      print('Provider: Item not found in list items: $vocabEntryId');
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



  // Reload the current vocabulary list with the same parameters
  Future<void> _reloadCurrentVocabularyList() async {
    if (_currentUserId == null) return;

    try {
      print('Provider: Reloading vocabulary list...');
      // Reset to first page and reload with the last known request
      _currentPage = 1;
      _vocabularyListItems = [];
      
      if (_lastListRequest != null) {
        print('Provider: Using last request parameters: ${_lastListRequest!.toJson()}');
        // Create a new request with the same parameters but page 1
        final reloadRequest = VocabularyListRequest(
          page: 1,
          limit: _lastListRequest!.limit,
          showFavoritesOnly: _lastListRequest!.showFavoritesOnly,
          showHidden: _lastListRequest!.showHidden,
          topicName: _lastListRequest!.topicName,
          categoryName: _lastListRequest!.categoryName,
          level: _lastListRequest!.level,
          searchTerm: _lastListRequest!.searchTerm,
        );
        
        await getVocabularyList(reloadRequest);
        print('Provider: Vocabulary list reload completed');
      } else {
        print('Provider: No last request available for reload');
      }
    } catch (e) {
      print('Provider: Error reloading vocabulary list: $e');
      _error = e.toString();
      notifyListeners();
    }
  }
} 