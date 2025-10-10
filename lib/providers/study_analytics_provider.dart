import 'package:flutter/foundation.dart';
import '../services/study_analytics_service.dart';

class StudyAnalyticsProvider with ChangeNotifier {
  // Study analytics data
  Map<String, dynamic>? _studyAnalytics;
  bool _isLoadingAnalytics = false;
  String? _analyticsError;

  // User study insights
  Map<String, dynamic>? _studyInsights;
  bool _isLoadingInsights = false;
  String? _insightsError;

  // Study progress
  Map<String, dynamic>? _studyProgress;
  bool _isLoadingProgress = false;
  String? _progressError;

  // Learning streaks
  Map<String, dynamic>? _learningStreaks;
  bool _isLoadingStreaks = false;
  String? _streaksError;

  // Difficulty analysis
  Map<String, dynamic>? _difficultyAnalysis;
  bool _isLoadingDifficulty = false;
  String? _difficultyError;

  // Getters
  Map<String, dynamic>? get studyAnalytics => _studyAnalytics;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  String? get analyticsError => _analyticsError;

  Map<String, dynamic>? get studyInsights => _studyInsights;
  bool get isLoadingInsights => _isLoadingInsights;
  String? get insightsError => _insightsError;

  Map<String, dynamic>? get studyProgress => _studyProgress;
  bool get isLoadingProgress => _isLoadingProgress;
  String? get progressError => _progressError;

  Map<String, dynamic>? get learningStreaks => _learningStreaks;
  bool get isLoadingStreaks => _isLoadingStreaks;
  String? get streaksError => _streaksError;

  Map<String, dynamic>? get difficultyAnalysis => _difficultyAnalysis;
  bool get isLoadingDifficulty => _isLoadingDifficulty;
  String? get difficultyError => _difficultyError;

  /// Load study analytics
  Future<void> loadStudyAnalytics(
    String language, {
    String? level,
    String timePeriod = 'today',
    int limit = 50,
  }) async {
    _isLoadingAnalytics = true;
    _analyticsError = null;
    notifyListeners();

    try {
      _studyAnalytics = await StudyAnalyticsService.getStudyAnalytics(
        language,
        level: level,
        timePeriod: timePeriod,
        limit: limit,
      );

      print('📊 Study analytics loaded for $language');
    } catch (e) {
      _analyticsError = e.toString();
      print('📊 Study analytics error: $e');
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  /// Load user study insights
  Future<void> loadStudyInsights(String username) async {
    _isLoadingInsights = true;
    _insightsError = null;
    notifyListeners();

    try {
      _studyInsights = await StudyAnalyticsService.getUserStudyInsights(username);

      print('👤 Study insights loaded for $username');
    } catch (e) {
      _insightsError = e.toString();
      print('👤 Study insights error: $e');
    } finally {
      _isLoadingInsights = false;
      notifyListeners();
    }
  }

  /// Load study progress
  Future<void> loadStudyProgress(
    String username, {
    String? language,
    String? level,
    String timePeriod = 'week',
  }) async {
    _isLoadingProgress = true;
    _progressError = null;
    notifyListeners();

    try {
      _studyProgress = await StudyAnalyticsService.getStudyProgress(
        username,
        language: language,
        level: level,
        timePeriod: timePeriod,
      );

      print('📈 Study progress loaded for $username');
    } catch (e) {
      _progressError = e.toString();
      print('📈 Study progress error: $e');
    } finally {
      _isLoadingProgress = false;
      notifyListeners();
    }
  }

  /// Load learning streaks
  Future<void> loadLearningStreaks(String username) async {
    _isLoadingStreaks = true;
    _streaksError = null;
    notifyListeners();

    try {
      _learningStreaks = await StudyAnalyticsService.getLearningStreaks(username);

      print('🔥 Learning streaks loaded for $username');
    } catch (e) {
      _streaksError = e.toString();
      print('🔥 Learning streaks error: $e');
    } finally {
      _isLoadingStreaks = false;
      notifyListeners();
    }
  }

  /// Load difficulty analysis
  Future<void> loadDifficultyAnalysis(
    String username, {
    String? language,
    String? level,
  }) async {
    _isLoadingDifficulty = true;
    _difficultyError = null;
    notifyListeners();

    try {
      _difficultyAnalysis = await StudyAnalyticsService.getDifficultyAnalysis(
        username,
        language: language,
        level: level,
      );

      print('🎯 Difficulty analysis loaded for $username');
    } catch (e) {
      _difficultyError = e.toString();
      print('🎯 Difficulty analysis error: $e');
    } finally {
      _isLoadingDifficulty = false;
      notifyListeners();
    }
  }

  /// Record word study
  Future<void> recordWordStudy(
    String username,
    String word,
    String language,
    String level,
    String studyType, {
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await StudyAnalyticsService.recordWordStudy(
        username,
        word,
        language,
        level,
        studyType,
        context: context,
        metadata: metadata,
      );

      print('📚 Word study recorded: $word ($studyType)');
    } catch (e) {
      print('📚 Word study recording error: $e');
      // Don't notify listeners - study recording is not critical
    }
  }

  /// Record learning session
  Future<void> recordLearningSession(
    String username,
    String sessionType,
    String language,
    String level, {
    int durationMinutes = 0,
    int wordsStudied = 0,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await StudyAnalyticsService.recordLearningSession(
        username,
        sessionType,
        language,
        level,
        durationMinutes: durationMinutes,
        wordsStudied: wordsStudied,
        metadata: metadata,
      );

      print('⏱️ Learning session recorded: $sessionType');
    } catch (e) {
      print('⏱️ Learning session recording error: $e');
      // Don't notify listeners - session recording is not critical
    }
  }

  /// Refresh all analytics data
  Future<void> refreshAllAnalytics(
    String username,
    String language, {
    String? level,
  }) async {
    await Future.wait([
      loadStudyInsights(username),
      loadStudyProgress(username, language: language, level: level),
      loadLearningStreaks(username),
      loadDifficultyAnalysis(username, language: language, level: level),
    ]);
  }

  /// Clear all data
  void clearData() {
    _studyAnalytics = null;
    _studyInsights = null;
    _studyProgress = null;
    _learningStreaks = null;
    _difficultyAnalysis = null;
    _analyticsError = null;
    _insightsError = null;
    _progressError = null;
    _streaksError = null;
    _difficultyError = null;
    notifyListeners();
  }
}
