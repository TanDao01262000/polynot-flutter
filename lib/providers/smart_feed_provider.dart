import 'package:flutter/foundation.dart';
import '../services/smart_feed_service.dart';

class SmartFeedProvider with ChangeNotifier {
  // Feed data
  List<Map<String, dynamic>> _feedItems = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Trending words
  List<String> _trendingWords = [];
  bool _isLoadingTrending = false;
  String? _trendingError;

  // Recommendations
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoadingRecommendations = false;
  String? _recommendationsError;

  // Level peers
  List<Map<String, dynamic>> _levelPeers = [];
  bool _isLoadingLevelPeers = false;
  String? _levelPeersError;

  // Getters
  List<Map<String, dynamic>> get feedItems => _feedItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  List<String> get trendingWords => _trendingWords;
  bool get isLoadingTrending => _isLoadingTrending;
  String? get trendingError => _trendingError;

  List<Map<String, dynamic>> get recommendations => _recommendations;
  bool get isLoadingRecommendations => _isLoadingRecommendations;
  String? get recommendationsError => _recommendationsError;

  List<Map<String, dynamic>> get levelPeers => _levelPeers;
  bool get isLoadingLevelPeers => _isLoadingLevelPeers;
  String? get levelPeersError => _levelPeersError;

  /// Load smart feed for a user
  Future<void> loadSmartFeed(
    String username, {
    bool refresh = false,
    double personalizationScore = 0.7,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _feedItems.clear();
      _hasMoreData = true;
    }

    if (!_hasMoreData || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final feedData = await SmartFeedService.getSmartFeed(
        username,
        page: _currentPage,
        limit: 20,
        personalizationScore: personalizationScore,
      );

      if (refresh) {
        _feedItems = List<Map<String, dynamic>>.from(feedData['items'] ?? []);
      } else {
        _feedItems.addAll(List<Map<String, dynamic>>.from(feedData['items'] ?? []));
      }

      _hasMoreData = feedData['has_more'] ?? false;
      _currentPage++;

      print('🔍 Smart Feed loaded: ${_feedItems.length} items');
    } catch (e) {
      _error = e.toString();
      print('🔍 Smart Feed Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load trending words
  Future<void> loadTrendingWords(
    String language,
    String level, {
    int limit = 20,
  }) async {
    _isLoadingTrending = true;
    _trendingError = null;
    notifyListeners();

    try {
      _trendingWords = await SmartFeedService.getTrendingWords(
        language,
        level,
        limit: limit,
      );

      print('📈 Trending words loaded: ${_trendingWords.length} words');
    } catch (e) {
      _trendingError = e.toString();
      print('📈 Trending words error: $e');
    } finally {
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  /// Load personalized recommendations
  Future<void> loadRecommendations(
    String username, {
    int limit = 10,
    String? category,
    String? difficulty,
  }) async {
    _isLoadingRecommendations = true;
    _recommendationsError = null;
    notifyListeners();

    try {
      final data = await SmartFeedService.getPersonalizedRecommendations(
        username,
        limit: limit,
        category: category,
        difficulty: difficulty,
      );

      _recommendations = List<Map<String, dynamic>>.from(data['recommendations'] ?? []);

      print('🎯 Recommendations loaded: ${_recommendations.length} items');
    } catch (e) {
      _recommendationsError = e.toString();
      print('🎯 Recommendations error: $e');
    } finally {
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  /// Load level peers
  Future<void> loadLevelPeers(
    String username,
    String level, {
    int limit = 10,
  }) async {
    _isLoadingLevelPeers = true;
    _levelPeersError = null;
    notifyListeners();

    try {
      _levelPeers = await SmartFeedService.getLevelPeers(
        username,
        level,
        limit: limit,
      );

      print('👥 Level peers loaded: ${_levelPeers.length} peers');
    } catch (e) {
      _levelPeersError = e.toString();
      print('👥 Level peers error: $e');
    } finally {
      _isLoadingLevelPeers = false;
      notifyListeners();
    }
  }

  /// Record user interaction
  Future<void> recordInteraction(
    String username,
    String contentType,
    String contentId,
    String interactionType, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await SmartFeedService.recordInteraction(
        username,
        contentType,
        contentId,
        interactionType,
        metadata: metadata,
      );

      print('📝 Interaction recorded: $interactionType for $contentType');
    } catch (e) {
      print('📝 Interaction recording error: $e');
      // Don't notify listeners - interaction recording is not critical
    }
  }

  /// Refresh all data
  Future<void> refreshAll(String username, String language, String level) async {
    await Future.wait([
      loadSmartFeed(username, refresh: true),
      loadTrendingWords(language, level),
      loadRecommendations(username),
      loadLevelPeers(username, level),
    ]);
  }

  /// Clear all data
  void clearData() {
    _feedItems.clear();
    _trendingWords.clear();
    _recommendations.clear();
    _levelPeers.clear();
    _error = null;
    _trendingError = null;
    _recommendationsError = null;
    _levelPeersError = null;
    _currentPage = 1;
    _hasMoreData = true;
    notifyListeners();
  }
}
