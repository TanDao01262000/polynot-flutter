import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/social_models.dart';
import '../services/social_service.dart';

class SocialProvider with ChangeNotifier {
  // Base URL for API calls
  static String get _baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';

  // Achievements
  List<SocialAchievement> _achievements = [];
  bool _isLoadingAchievements = false;
  String? _achievementsError;
  
  // Available Achievements
  List<AvailableAchievement> _availableAchievements = [];
  bool _isLoadingAvailableAchievements = false;
  String? _availableAchievementsError;

  // Leaderboard
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoadingLeaderboard = false;
  String? _leaderboardError;

  // Posts
  List<SocialPost> _posts = [];
  bool _isLoadingPosts = false;
  String? _postsError;

  // Study Insights
  UserStudyInsights? _studyInsights;
  bool _isLoadingStudyInsights = false;
  String? _studyInsightsError;

  // User Points
  UserPoints? _userPoints;
  bool _isLoadingPoints = false;
  String? _pointsError;

  // Trending Words
  List<TrendingWord> _trendingWords = [];
  bool _isLoadingTrendingWords = false;
  String? _trendingWordsError;

  // Getters
  List<SocialAchievement> get achievements => _achievements;
  bool get isLoadingAchievements => _isLoadingAchievements;
  String? get achievementsError => _achievementsError;
  
  List<AvailableAchievement> get availableAchievements => _availableAchievements;
  bool get isLoadingAvailableAchievements => _isLoadingAvailableAchievements;
  String? get availableAchievementsError => _availableAchievementsError;

  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get isLoadingLeaderboard => _isLoadingLeaderboard;
  String? get leaderboardError => _leaderboardError;

  List<SocialPost> get posts => _posts;
  bool get isLoadingPosts => _isLoadingPosts;
  String? get postsError => _postsError;

  UserStudyInsights? get studyInsights => _studyInsights;
  bool get isLoadingStudyInsights => _isLoadingStudyInsights;
  String? get studyInsightsError => _studyInsightsError;

  UserPoints? get userPoints => _userPoints;
  bool get isLoadingPoints => _isLoadingPoints;
  String? get pointsError => _pointsError;

  List<TrendingWord> get trendingWords => _trendingWords;
  bool get isLoadingTrendingWords => _isLoadingTrendingWords;
  String? get trendingWordsError => _trendingWordsError;

  // Load achievements
  Future<void> loadAchievements(String userId) async {
    _isLoadingAchievements = true;
    _achievementsError = null;
    notifyListeners();

    try {
      final response = await SocialService.getUserAchievements(userId);
      _achievements = response.achievements;
      
      _isLoadingAchievements = false;
      notifyListeners();
    } catch (e) {
      print('Error loading achievements: $e');
      _achievementsError = e.toString();
      _isLoadingAchievements = false;
      notifyListeners();
    }
  }

  // Check achievements (manual trigger)
  Future<void> checkAchievements(String userId) async {
    _isLoadingAchievements = true;
    _achievementsError = null;
    notifyListeners();

    try {
      final response = await SocialService.checkUserAchievements(userId);
      _achievements = response.achievements;
      
      _isLoadingAchievements = false;
      notifyListeners();
    } catch (e) {
      print('Error checking achievements: $e');
      _achievementsError = e.toString();
      _isLoadingAchievements = false;
      notifyListeners();
    }
  }

  // Load available achievements
  Future<void> loadAvailableAchievements() async {
    _isLoadingAvailableAchievements = true;
    _availableAchievementsError = null;
    notifyListeners();

    try {
      final response = await SocialService.getAvailableAchievements();
      _availableAchievements = response.achievements;
      
      _isLoadingAvailableAchievements = false;
      notifyListeners();
    } catch (e) {
      print('Error loading available achievements: $e');
      _availableAchievementsError = e.toString();
      _isLoadingAvailableAchievements = false;
      notifyListeners();
    }
  }

  // Load leaderboard (uses user_id)
  Future<void> loadLeaderboard({required String userId, int limit = 50}) async {
    _isLoadingLeaderboard = true;
    _leaderboardError = null;
    notifyListeners();

    try {
      print('🔐 Loading leaderboard for user ID: $userId');
      
      // Call the real backend API using SocialService
      final leaderboardData = await SocialService.getLeaderboard(userId, limit: limit);
      
      print('🔐 Leaderboard data: $leaderboardData');
      
      _leaderboard = leaderboardData.map((entry) {
        print('🔐 Processing entry: $entry');
        return LeaderboardEntry(
          rank: entry['rank'] ?? 0,
          userName: entry['user_name'] ?? '',
          totalPoints: entry['total_points'] ?? 0,
          level: entry['level'] ?? 1,
          badges: List<String>.from(entry['badges'] ?? []),
          streakDays: entry['streak_days'] ?? 0,
          avatarUrl: entry['avatar_url'],
        );
      }).toList();
      
      print('🔐 Leaderboard loaded: ${_leaderboard.length} entries');
      
      _isLoadingLeaderboard = false;
      notifyListeners();
    } catch (e) {
      print('🔐 Error loading leaderboard: $e');
      _leaderboardError = e.toString();
      _isLoadingLeaderboard = false;
      notifyListeners();
    }
  }

  // Load leaderboard (uses user_name for backward compatibility)
  /// @deprecated Use loadLeaderboard() with user_id instead
  Future<void> loadLeaderboardByUsername({required String userName, int limit = 50}) async {
    _isLoadingLeaderboard = true;
    _leaderboardError = null;
    notifyListeners();

    try {
      print('🔐 Loading leaderboard for user: $userName');
      
      // Get user ID from username
      final userId = await SocialService.getUserIdFromUsername(userName);
      if (userId == null) {
        throw Exception('Could not find user ID for username: $userName');
      }
      
      // Use the new user_id based method
      await loadLeaderboard(userId: userId, limit: limit);
    } catch (e) {
      print('🔐 Error loading leaderboard by username: $e');
      _leaderboardError = e.toString();
      _isLoadingLeaderboard = false;
      notifyListeners();
    }
  }

  // Create post
  Future<void> createPost({
    required String userId,
    required String postType,
    required String content,
    required String language,
    required String level,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('🔐 Creating post for user ID: $userId');
      
      final postData = {
        'title': _generatePostTitle(postType, content),
        'post_type': postType,
        'content': content,
        'language': language,
        'level': level,
        'metadata': metadata ?? {},
      };
      
      await SocialService.createPost(userId, postData);
      print('🔐 Post created successfully');
    } catch (e) {
      print('🔐 Error creating post: $e');
      rethrow;
    }
  }

  // Update post
  Future<void> updatePost({
    required String postId,
    required String userName,
    String? title,
    String? content,
    String? visibility,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('✏️ Updating post: $postId for user: $userName');
      
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (visibility != null) updates['visibility'] = visibility;
      if (metadata != null) updates['metadata'] = metadata;
      
      await SocialService.updatePost(postId, userName, updates);
      print('✏️ Post updated successfully');
    } catch (e) {
      print('✏️ Error updating post: $e');
      rethrow;
    }
  }

  // Delete post
  Future<void> deletePost({
    required String postId,
    required String userName,
  }) async {
    try {
      print('🗑️ Deleting post: $postId for user: $userName');
      
      await SocialService.deletePost(postId, userName);
      print('🗑️ Post deleted successfully');
    } catch (e) {
      print('🗑️ Error deleting post: $e');
      rethrow;
    }
  }

  // Load posts
  Future<void> loadPosts({int limit = 20}) async {
    _isLoadingPosts = true;
    _postsError = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Mock data for now
      _posts = [];
      
      _isLoadingPosts = false;
      notifyListeners();
    } catch (e) {
      _postsError = e.toString();
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  // Load user points (uses user_id)
  Future<void> loadUserPoints(String userId) async {
    _isLoadingPoints = true;
    _pointsError = null;
    notifyListeners();

    try {
      print('🔐 Loading user points for user ID: $userId');
      
      // Call the real backend API using SocialService
      final pointsData = await SocialService.getUserPoints(userId);
      
      _userPoints = UserPoints.fromJson(pointsData);
      
      print('🔐 User points loaded successfully');
      
      _isLoadingPoints = false;
      notifyListeners();
    } catch (e) {
      print('🔐 Error loading user points: $e');
      _pointsError = e.toString();
      _isLoadingPoints = false;
      notifyListeners();
    }
  }

  // Load study insights (uses user_id)
  Future<void> loadStudyInsights(String userId) async {
    _isLoadingStudyInsights = true;
    _studyInsightsError = null;
    notifyListeners();

    try {
      // Call the real backend API
      final response = await http.get(
        Uri.parse('$_baseUrl/study/users/$userId/insights'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        _studyInsights = UserStudyInsights(
          userName: data['user_name'] ?? userId, // Fallback to userId if user_name not provided
          wordsStudiedToday: data['words_studied_today'] ?? 0,
          wordsStudiedThisWeek: data['words_studied_this_week'] ?? 0,
          totalWordsStudied: data['total_words_studied'] ?? 0,
          mostDifficultWords: List<String>.from(data['most_difficult_words'] ?? []),
          studyStreak: data['study_streak'] ?? 0,
          levelProgress: data['level_progress'] ?? {},
          globalRank: data['global_rank'] ?? 0,
          levelRank: data['level_rank'] ?? 0,
        );
        
        print('🔐 Study insights loaded for user ID: $userId');
      } else {
        throw Exception('Failed to load study insights: ${response.statusCode}');
      }
      
      _isLoadingStudyInsights = false;
      notifyListeners();
    } catch (e) {
      print('🔐 Error loading study insights: $e');
      _studyInsightsError = e.toString();
      _isLoadingStudyInsights = false;
      notifyListeners();
    }
  }

  // Load study insights (uses user_name for backward compatibility)
  /// @deprecated Use loadStudyInsights() with user_id instead
  Future<void> loadStudyInsightsByUsername(String userName) async {
    try {
      // Get user ID from username
      final userId = await SocialService.getUserIdFromUsername(userName);
      if (userId == null) {
        throw Exception('Could not find user ID for username: $userName');
      }
      
      // Use the new user_id based method
      await loadStudyInsights(userId);
    } catch (e) {
      print('🔐 Error loading study insights by username: $e');
      _studyInsightsError = e.toString();
      _isLoadingStudyInsights = false;
      notifyListeners();
    }
  }

  // Load trending words
  Future<void> loadTrendingWords({int limit = 20}) async {
    _isLoadingTrendingWords = true;
    _trendingWordsError = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Mock data for now
      _trendingWords = [
        TrendingWord(
          contentType: 'vocabulary',
          content: 'serendipity',
          language: 'English',
          level: 'B2',
          popularityScore: 95.5,
          usageCount: 1250,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        TrendingWord(
          contentType: 'vocabulary',
          content: 'ubiquitous',
          language: 'English',
          level: 'C1',
          popularityScore: 87.2,
          usageCount: 980,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        TrendingWord(
          contentType: 'vocabulary',
          content: 'ephemeral',
          language: 'English',
          level: 'C2',
          popularityScore: 82.1,
          usageCount: 750,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];
      
      _isLoadingTrendingWords = false;
      notifyListeners();
    } catch (e) {
      _trendingWordsError = e.toString();
      _isLoadingTrendingWords = false;
      notifyListeners();
    }
  }

  // Generate post title based on post type and content
  String _generatePostTitle(String postType, String content) {
    final truncatedContent = content.length > 50 
        ? '${content.substring(0, 50)}...' 
        : content;
    
    switch (postType) {
      case PostTypes.learningTip:
        return 'Learning Tip: $truncatedContent';
      case PostTypes.achievement:
        return 'Achievement Unlocked: $truncatedContent';
      case PostTypes.milestone:
        return 'Milestone Reached: $truncatedContent';
      case PostTypes.challenge:
        return 'Challenge Accepted: $truncatedContent';
      default:
        return truncatedContent;
    }
  }

  // Helper methods for user points
  double getLevelProgressPercentage() {
    if (_userPoints == null) return 0.0;
    
    final currentPoints = _userPoints!.totalPoints;
    final nextLevelPoints = _userPoints!.nextLevelPoints;
    final currentLevelPoints = _getCurrentLevelMinPoints(_userPoints!.level);
    
    final pointsInCurrentLevel = currentPoints - currentLevelPoints;
    final pointsNeededForNextLevel = nextLevelPoints - currentLevelPoints;
    
    if (pointsNeededForNextLevel <= 0) return 100.0;
    
    return (pointsInCurrentLevel / pointsNeededForNextLevel) * 100.0;
  }

  String getLevelDisplayName(int level) {
    if (level >= 10) return 'Expert';
    if (level >= 8) return 'Advanced';
    if (level >= 6) return 'Intermediate';
    if (level >= 4) return 'Beginner+';
    if (level >= 2) return 'Beginner';
    return 'Newcomer';
  }

  int _getCurrentLevelMinPoints(int level) {
    // Simple calculation: each level requires 100 more points than the previous
    if (level <= 1) return 0;
    return (level - 1) * 100;
  }

  // Clear all data
  void clearData() {
    _achievements.clear();
    _leaderboard.clear();
    _posts.clear();
    _trendingWords.clear();
    _studyInsights = null;
    _userPoints = null;
    _achievementsError = null;
    _leaderboardError = null;
    _postsError = null;
    _trendingWordsError = null;
    _studyInsightsError = null;
    _pointsError = null;
    notifyListeners();
  }
}
