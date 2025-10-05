
import '../utils/date_utils.dart' as app_date_utils;

// Social Post Model
class SocialPost {
  final String id;
  final String? userId;  // Added userId field
  final String userName;
  final String postType;
  final String title;
  final String content;
  final String visibility;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int pointsEarned;
  final bool isLiked;
  final String? authorAvatar;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  SocialPost({
    required this.id,
    this.userId,  // Added userId parameter
    required this.userName,
    required this.postType,
    required this.title,
    required this.content,
    required this.visibility,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.pointsEarned,
    required this.isLiked,
    this.authorAvatar,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] ?? '',
      userId: json['user_id'],  // Added userId parsing
      userName: json['user_name'] ?? '',
      postType: json['post_type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      visibility: json['visibility'] ?? 'public',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      pointsEarned: json['points_earned'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      authorAvatar: json['author_avatar'],
      metadata: json['metadata'],
      createdAt: app_date_utils.DateUtils.parseDate(json['created_at']),
      updatedAt: app_date_utils.DateUtils.parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,  // Added userId to JSON
      'user_name': userName,
      'post_type': postType,
      'title': title,
      'content': content,
      'visibility': visibility,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'points_earned': pointsEarned,
      'is_liked': isLiked,
      'author_avatar': authorAvatar,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SocialPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? postType,
    String? title,
    String? content,
    String? visibility,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? pointsEarned,
    bool? isLiked,
    String? authorAvatar,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      postType: postType ?? this.postType,
      title: title ?? this.title,
      content: content ?? this.content,
      visibility: visibility ?? this.visibility,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      isLiked: isLiked ?? this.isLiked,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Comment Model
class PostComment {
  final String id;
  final String postId;
  final String userName;
  final String content;
  final int likesCount;
  final bool isLiked;
  final String? authorAvatar;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.postId,
    required this.userName,
    required this.content,
    required this.likesCount,
    required this.isLiked,
    this.authorAvatar,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] ?? '',
      postId: json['post_id'] ?? '',
      userName: json['user_name'] ?? '',
      content: json['content'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      authorAvatar: json['author_avatar'],
      createdAt: app_date_utils.DateUtils.parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_name': userName,
      'content': content,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'author_avatar': authorAvatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// User Points Model
class UserPoints {
  final int totalPoints;
  final int availablePoints;
  final int redeemedPoints;
  final int level;
  final int nextLevelPoints;
  final List<String> badges;

  UserPoints({
    required this.totalPoints,
    required this.availablePoints,
    required this.redeemedPoints,
    required this.level,
    required this.nextLevelPoints,
    required this.badges,
  });

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      totalPoints: json['total_points'] ?? 0,
      availablePoints: json['available_points'] ?? 0,
      redeemedPoints: json['redeemed_points'] ?? 0,
      level: json['level'] ?? 1,
      nextLevelPoints: json['next_level_points'] ?? 100,
      badges: List<String>.from(json['badges'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_points': totalPoints,
      'available_points': availablePoints,
      'redeemed_points': redeemedPoints,
      'level': level,
      'next_level_points': nextLevelPoints,
      'badges': badges,
    };
  }
}

// Achievement Model (for unlocked achievements)
class SocialAchievement {
  final String id;
  final String achievementId;
  final String achievementName;
  final String description;
  final int pointsEarned;
  final String icon;
  final DateTime unlockedAt;

  SocialAchievement({
    required this.id,
    required this.achievementId,
    required this.achievementName,
    required this.description,
    required this.pointsEarned,
    required this.icon,
    required this.unlockedAt,
  });

  factory SocialAchievement.fromJson(Map<String, dynamic> json) {
    return SocialAchievement(
      id: json['id'] ?? '',
      achievementId: json['achievement_id'] ?? '',
      achievementName: json['achievement_name'] ?? '',
      description: json['description'] ?? '',
      pointsEarned: json['points_earned'] ?? 0,
      icon: json['icon'] ?? '🏆',
      unlockedAt: app_date_utils.DateUtils.parseDate(json['unlocked_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'achievement_id': achievementId,
      'achievement_name': achievementName,
      'description': description,
      'points_earned': pointsEarned,
      'icon': icon,
      'unlocked_at': unlockedAt.toIso8601String(),
    };
  }
}

// Available Achievement Model (for all available achievements)
class AvailableAchievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int points;

  AvailableAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.points,
  });

  factory AvailableAchievement.fromJson(Map<String, dynamic> json) {
    return AvailableAchievement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'points': points,
    };
  }
}

// Achievement Response Models
class UserAchievementsResponse {
  final List<SocialAchievement> achievements;
  final int count;

  UserAchievementsResponse({
    required this.achievements,
    required this.count,
  });

  factory UserAchievementsResponse.fromJson(Map<String, dynamic> json) {
    return UserAchievementsResponse(
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((item) => SocialAchievement.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      count: json['count'] ?? 0,
    );
  }
}

class AvailableAchievementsResponse {
  final List<AvailableAchievement> achievements;
  final int total;

  AvailableAchievementsResponse({
    required this.achievements,
    required this.total,
  });

  factory AvailableAchievementsResponse.fromJson(Map<String, dynamic> json) {
    return AvailableAchievementsResponse(
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((item) => AvailableAchievement.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      total: json['total'] ?? 0,
    );
  }
}

class AchievementCheckResponse {
  final String message;
  final List<SocialAchievement> achievements;
  final int count;

  AchievementCheckResponse({
    required this.message,
    required this.achievements,
    required this.count,
  });

  factory AchievementCheckResponse.fromJson(Map<String, dynamic> json) {
    return AchievementCheckResponse(
      message: json['message'] ?? '',
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((item) => SocialAchievement.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      count: json['count'] ?? 0,
    );
  }
}

// Leaderboard Entry Model
class LeaderboardEntry {
  final int rank;
  final String userName;
  final int totalPoints;
  final int level;
  final List<String> badges;
  final int streakDays;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.rank,
    required this.userName,
    required this.totalPoints,
    required this.level,
    required this.badges,
    required this.streakDays,
    this.avatarUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userName: json['user_name'] ?? '',
      totalPoints: json['total_points'] ?? 0,
      level: json['level'] ?? 1,
      badges: List<String>.from(json['badges'] ?? []),
      streakDays: json['streak_days'] ?? 0,
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_name': userName,
      'total_points': totalPoints,
      'level': level,
      'badges': badges,
      'streak_days': streakDays,
      'avatar_url': avatarUrl,
    };
  }
}

// Study Analytics Models
class WordAnalytics {
  final String word;
  final String language;
  final int totalStudiers;
  final int todayStudiers;
  final int thisWeekStudiers;
  final Map<String, int> levelBreakdown;
  final Map<String, int> studyTypes;
  final double averageDifficulty;
  final String popularityTrend;
  final DateTime lastUpdated;

  WordAnalytics({
    required this.word,
    required this.language,
    required this.totalStudiers,
    required this.todayStudiers,
    required this.thisWeekStudiers,
    required this.levelBreakdown,
    required this.studyTypes,
    required this.averageDifficulty,
    required this.popularityTrend,
    required this.lastUpdated,
  });

  factory WordAnalytics.fromJson(Map<String, dynamic> json) {
    return WordAnalytics(
      word: json['word'] ?? '',
      language: json['language'] ?? '',
      totalStudiers: json['total_studiers'] ?? 0,
      todayStudiers: json['today_studiers'] ?? 0,
      thisWeekStudiers: json['this_week_studiers'] ?? 0,
      levelBreakdown: Map<String, int>.from(json['level_breakdown'] ?? {}),
      studyTypes: Map<String, int>.from(json['study_types'] ?? {}),
      averageDifficulty: (json['average_difficulty'] ?? 0.0).toDouble(),
      popularityTrend: json['popularity_trend'] ?? 'stable',
      lastUpdated: app_date_utils.DateUtils.parseDate(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'language': language,
      'total_studiers': totalStudiers,
      'today_studiers': todayStudiers,
      'this_week_studiers': thisWeekStudiers,
      'level_breakdown': levelBreakdown,
      'study_types': studyTypes,
      'average_difficulty': averageDifficulty,
      'popularity_trend': popularityTrend,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class UserStudyInsights {
  final String userName;
  final int wordsStudiedToday;
  final int wordsStudiedThisWeek;
  final int totalWordsStudied;
  final List<String> mostDifficultWords;
  final int studyStreak;
  final Map<String, dynamic> levelProgress;
  final int globalRank;
  final int levelRank;

  UserStudyInsights({
    required this.userName,
    required this.wordsStudiedToday,
    required this.wordsStudiedThisWeek,
    required this.totalWordsStudied,
    required this.mostDifficultWords,
    required this.studyStreak,
    required this.levelProgress,
    required this.globalRank,
    required this.levelRank,
  });

  factory UserStudyInsights.fromJson(Map<String, dynamic> json) {
    return UserStudyInsights(
      userName: json['user_name'] ?? '',
      wordsStudiedToday: json['words_studied_today'] ?? 0,
      wordsStudiedThisWeek: json['words_studied_this_week'] ?? 0,
      totalWordsStudied: json['total_words_studied'] ?? 0,
      mostDifficultWords: List<String>.from(json['most_difficult_words'] ?? []),
      studyStreak: json['study_streak'] ?? 0,
      levelProgress: json['level_progress'] ?? {},
      globalRank: json['global_rank'] ?? 0,
      levelRank: json['level_rank'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'words_studied_today': wordsStudiedToday,
      'words_studied_this_week': wordsStudiedThisWeek,
      'total_words_studied': totalWordsStudied,
      'most_difficult_words': mostDifficultWords,
      'study_streak': studyStreak,
      'level_progress': levelProgress,
      'global_rank': globalRank,
      'level_rank': levelRank,
    };
  }
}

// Trending Word Model
class TrendingWord {
  final String contentType;
  final String content;
  final String language;
  final String level;
  final double popularityScore;
  final int usageCount;
  final DateTime lastUpdated;

  TrendingWord({
    required this.contentType,
    required this.content,
    required this.language,
    required this.level,
    required this.popularityScore,
    required this.usageCount,
    required this.lastUpdated,
  });

  factory TrendingWord.fromJson(Map<String, dynamic> json) {
    return TrendingWord(
      contentType: json['content_type'] ?? '',
      content: json['content'] ?? '',
      language: json['language'] ?? '',
      level: json['level'] ?? '',
      popularityScore: (json['popularity_score'] ?? 0.0).toDouble(),
      usageCount: json['usage_count'] ?? 0,
      lastUpdated: app_date_utils.DateUtils.parseDate(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_type': contentType,
      'content': content,
      'language': language,
      'level': level,
      'popularity_score': popularityScore,
      'usage_count': usageCount,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

// Smart Feed Recommendation Model
class SmartFeedRecommendation {
  final String contentId;
  final String contentType;
  final String title;
  final String content;
  final double relevanceScore;
  final String reason;
  final String authorLevel;
  final String targetLanguage;

  SmartFeedRecommendation({
    required this.contentId,
    required this.contentType,
    required this.title,
    required this.content,
    required this.relevanceScore,
    required this.reason,
    required this.authorLevel,
    required this.targetLanguage,
  });

  factory SmartFeedRecommendation.fromJson(Map<String, dynamic> json) {
    return SmartFeedRecommendation(
      contentId: json['content_id'] ?? '',
      contentType: json['content_type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      relevanceScore: (json['relevance_score'] ?? 0.0).toDouble(),
      reason: json['reason'] ?? '',
      authorLevel: json['author_level'] ?? '',
      targetLanguage: json['target_language'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_id': contentId,
      'content_type': contentType,
      'title': title,
      'content': content,
      'relevance_score': relevanceScore,
      'reason': reason,
      'author_level': authorLevel,
      'target_language': targetLanguage,
    };
  }
}

// Privacy Settings Model
class PrivacySettings {
  final String showPostsToLevel;
  final bool showAchievements;
  final bool showLearningProgress;
  final bool allowLevelFiltering;
  final bool studyGroupVisibility;

  PrivacySettings({
    required this.showPostsToLevel,
    required this.showAchievements,
    required this.showLearningProgress,
    required this.allowLevelFiltering,
    required this.studyGroupVisibility,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      showPostsToLevel: json['show_posts_to_level'] ?? 'same',
      showAchievements: json['show_achievements'] ?? true,
      showLearningProgress: json['show_learning_progress'] ?? true,
      allowLevelFiltering: json['allow_level_filtering'] ?? true,
      studyGroupVisibility: json['study_group_visibility'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_posts_to_level': showPostsToLevel,
      'show_achievements': showAchievements,
      'show_learning_progress': showLearningProgress,
      'allow_level_filtering': allowLevelFiltering,
      'study_group_visibility': studyGroupVisibility,
    };
  }
}

// Feed Response Models
class FeedResponse {
  final List<SocialPost> posts;
  final int totalPosts;
  final int currentPage;
  final int totalPages;
  final bool hasNext;

  FeedResponse({
    required this.posts,
    required this.totalPosts,
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
  });

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      posts: (json['posts'] as List?)
          ?.map((post) => SocialPost.fromJson(post))
          .toList() ?? [],
      totalPosts: json['total_posts'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      hasNext: json['has_next'] ?? false,
    );
  }
}

class SmartFeedResponse {
  final List<SocialPost> posts;
  final List<SmartFeedRecommendation> recommendations;
  final List<TrendingWord> trendingContent;
  final int totalPosts;
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final String feedAlgorithm;
  final bool personalizationApplied;

  SmartFeedResponse({
    required this.posts,
    required this.recommendations,
    required this.trendingContent,
    required this.totalPosts,
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.feedAlgorithm,
    required this.personalizationApplied,
  });

  factory SmartFeedResponse.fromJson(Map<String, dynamic> json) {
    return SmartFeedResponse(
      posts: (json['posts'] as List?)
          ?.map((post) => SocialPost.fromJson(post))
          .toList() ?? [],
      recommendations: (json['recommendations'] as List?)
          ?.map((rec) => SmartFeedRecommendation.fromJson(rec))
          .toList() ?? [],
      trendingContent: (json['trending_content'] as List?)
          ?.map((trend) => TrendingWord.fromJson(trend))
          .toList() ?? [],
      totalPosts: json['total_posts'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      hasNext: json['has_next'] ?? false,
      feedAlgorithm: json['feed_algorithm'] ?? 'basic',
      personalizationApplied: json['personalization_applied'] ?? false,
    );
  }
}

class LeaderboardResponse {
  final List<LeaderboardEntry> leaderboard;
  final int? currentUserRank;

  LeaderboardResponse({
    required this.leaderboard,
    this.currentUserRank,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      leaderboard: (json['leaderboard'] as List?)
          ?.map((entry) => LeaderboardEntry.fromJson(entry))
          .toList() ?? [],
      currentUserRank: json['current_user_rank'],
    );
  }
}

// Post Type Constants
class PostTypes {
  static const String achievement = 'achievement';
  static const String levelUp = 'level_up';
  static const String streak = 'streak';
  static const String conversation = 'conversation';
  static const String learningTip = 'learning_tip';
  static const String milestone = 'milestone';
  static const String challenge = 'challenge';
}

// Visibility Constants
class PostVisibility {
  static const String public = 'public';
  static const String friends = 'friends';
  static const String private = 'private';
  static const String levelRestricted = 'level_restricted';
  static const String studyGroup = 'study_group';
}

// Point Values Constants
class PointValues {
  static const Map<String, int> values = {
    'post_created': 10,
    'post_liked': 1,
    'post_shared': 5,
    'comment_created': 3,
    'achievement_unlocked': 25,
    'level_up': 50,
    'streak_7_days': 30,
    'streak_30_days': 100,
    'conversation_completed': 5,
    'daily_login': 2,
    'profile_completed': 20,
    'first_post': 15,
    'first_comment': 5,
    'first_follow': 10,
    'milestone_reached': 40,
  };
}

// Level Thresholds Constants
class LevelThresholds {
  static const Map<int, int> thresholds = {
    1: 0,
    2: 100,
    3: 300,
    4: 600,
    5: 1000,
    6: 1500,
    7: 2200,
    8: 3000,
    9: 4000,
    10: 5000,
  };
}

// Enhanced News Feed Response Model
class NewsFeedResponse {
  final List<SocialPost> posts;
  final int totalPosts;
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final List<ContentRecommendation>? recommendations;
  final List<TrendingContent>? trendingContent;
  final String feedAlgorithm;
  final bool personalizationApplied;

  NewsFeedResponse({
    required this.posts,
    required this.totalPosts,
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    this.recommendations,
    this.trendingContent,
    this.feedAlgorithm = 'smart_personalized',
    this.personalizationApplied = false,
  });

  factory NewsFeedResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing NewsFeedResponse...');
      print('🔍 Posts: ${json['posts']}');
      print('🔍 Recommendations: ${json['recommendations']}');
      print('🔍 Trending content: ${json['trending_content']}');
      
      List<SocialPost> posts = [];
      if (json['posts'] is List) {
        posts = (json['posts'] as List).map((postJson) {
          try {
            return SocialPost.fromJson(postJson as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing post: $e');
            print('Post JSON: $postJson');
            rethrow;
          }
        }).toList();
      }
      
      List<ContentRecommendation>? recommendations;
      if (json['recommendations'] is List) {
        try {
          recommendations = (json['recommendations'] as List).map((recJson) {
            return ContentRecommendation.fromJson(recJson as Map<String, dynamic>);
          }).toList();
        } catch (e) {
          print('Error parsing recommendations: $e');
          print('Recommendations JSON: ${json['recommendations']}');
          recommendations = null;
        }
      }
      
      List<TrendingContent>? trendingContent;
      if (json['trending_content'] is List) {
        try {
          trendingContent = (json['trending_content'] as List).map((trendJson) {
            return TrendingContent.fromJson(trendJson as Map<String, dynamic>);
          }).toList();
        } catch (e) {
          print('Error parsing trending content: $e');
          print('Trending content JSON: ${json['trending_content']}');
          trendingContent = null;
        }
      }
      
      return NewsFeedResponse(
        posts: posts,
        totalPosts: json['total_posts'] ?? json['totalPosts'] ?? 0,
        currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
        totalPages: json['total_pages'] ?? json['totalPages'] ?? 1,
        hasNext: json['has_next'] ?? json['hasNext'] ?? false,
        recommendations: recommendations,
        trendingContent: trendingContent,
        feedAlgorithm: json['feed_algorithm'] ?? json['feedAlgorithm'] ?? 'smart_personalized',
        personalizationApplied: json['personalization_applied'] ?? json['personalizationApplied'] ?? false,
      );
    } catch (e) {
      print('Error parsing NewsFeedResponse: $e');
      print('JSON keys: ${json.keys.toList()}');
      print('Posts type: ${json['posts'].runtimeType}');
      if (json['posts'] is List && (json['posts'] as List).isNotEmpty) {
        print('First post type: ${(json['posts'] as List).first.runtimeType}');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.map((post) => post.toJson()).toList(),
      'total_posts': totalPosts,
      'current_page': currentPage,
      'total_pages': totalPages,
      'has_next': hasNext,
      'recommendations': recommendations?.map((rec) => rec.toJson()).toList(),
      'trending_content': trendingContent?.map((trend) => trend.toJson()).toList(),
      'feed_algorithm': feedAlgorithm,
      'personalization_applied': personalizationApplied,
    };
  }
}

// Content Recommendation Model
class ContentRecommendation {
  final String contentId;
  final String contentType;
  final String title;
  final String content;
  final double relevanceScore;
  final String reason;
  final String authorLevel;
  final String targetLanguage;

  ContentRecommendation({
    required this.contentId,
    required this.contentType,
    required this.title,
    required this.content,
    required this.relevanceScore,
    required this.reason,
    required this.authorLevel,
    required this.targetLanguage,
  });

  factory ContentRecommendation.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing ContentRecommendation: $json');
      return ContentRecommendation(
        contentId: json['content_id']?.toString() ?? '',
        contentType: json['content_type']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        relevanceScore: (json['relevance_score'] ?? 0.0).toDouble(),
        reason: json['reason']?.toString() ?? '',
        authorLevel: json['author_level']?.toString() ?? '',
        targetLanguage: json['target_language']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing ContentRecommendation: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'content_id': contentId,
      'content_type': contentType,
      'title': title,
      'content': content,
      'relevance_score': relevanceScore,
      'reason': reason,
      'author_level': authorLevel,
      'target_language': targetLanguage,
    };
  }
}

// Trending Content Model
class TrendingContent {
  final String contentType;
  final String content;
  final String language;
  final String level;
  final double popularityScore;
  final int usageCount;
  final DateTime lastUpdated;

  TrendingContent({
    required this.contentType,
    required this.content,
    required this.language,
    required this.level,
    required this.popularityScore,
    required this.usageCount,
    required this.lastUpdated,
  });

  factory TrendingContent.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing TrendingContent: $json');
      return TrendingContent(
        contentType: json['content_type']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        language: json['language']?.toString() ?? '',
        level: json['level']?.toString() ?? '',
        popularityScore: (json['popularity_score'] ?? 0.0).toDouble(),
        usageCount: json['usage_count'] ?? 0,
        lastUpdated: app_date_utils.DateUtils.parseDate(json['last_updated']),
      );
    } catch (e) {
      print('Error parsing TrendingContent: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'content_type': contentType,
      'content': content,
      'language': language,
      'level': level,
      'popularity_score': popularityScore,
      'usage_count': usageCount,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

// User Privacy Settings Model
class UserPrivacySettings {
  final String userName;
  final String showPostsToLevel;
  final bool showAchievements;
  final bool showLearningProgress;
  final bool allowLevelFiltering;
  final bool studyGroupVisibility;

  UserPrivacySettings({
    required this.userName,
    this.showPostsToLevel = 'same',
    this.showAchievements = true,
    this.showLearningProgress = true,
    this.allowLevelFiltering = true,
    this.studyGroupVisibility = true,
  });

  factory UserPrivacySettings.fromJson(Map<String, dynamic> json) {
    try {
      print('🔒 UserPrivacySettings.fromJson - Input JSON: $json');
      final settings = UserPrivacySettings(
        userName: json['user_name'] ?? '',
        showPostsToLevel: json['show_posts_to_level'] ?? 'same',
        showAchievements: json['show_achievements'] ?? true,
        showLearningProgress: json['show_learning_progress'] ?? true,
        allowLevelFiltering: json['allow_level_filtering'] ?? true,
        studyGroupVisibility: json['study_group_visibility'] ?? true,
      );
      print('🔒 UserPrivacySettings.fromJson - Created settings: $settings');
      return settings;
    } catch (e) {
      print('🔒 Error in UserPrivacySettings.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'show_posts_to_level': showPostsToLevel,
      'show_achievements': showAchievements,
      'show_learning_progress': showLearningProgress,
      'allow_level_filtering': allowLevelFiltering,
      'study_group_visibility': studyGroupVisibility,
    };
  }

  UserPrivacySettings copyWith({
    String? userName,
    String? showPostsToLevel,
    bool? showAchievements,
    bool? showLearningProgress,
    bool? allowLevelFiltering,
    bool? studyGroupVisibility,
  }) {
    return UserPrivacySettings(
      userName: userName ?? this.userName,
      showPostsToLevel: showPostsToLevel ?? this.showPostsToLevel,
      showAchievements: showAchievements ?? this.showAchievements,
      showLearningProgress: showLearningProgress ?? this.showLearningProgress,
      allowLevelFiltering: allowLevelFiltering ?? this.allowLevelFiltering,
      studyGroupVisibility: studyGroupVisibility ?? this.studyGroupVisibility,
    );
  }

  @override
  String toString() {
    return 'UserPrivacySettings(userName: $userName, showPostsToLevel: $showPostsToLevel, showAchievements: $showAchievements, showLearningProgress: $showLearningProgress, allowLevelFiltering: $allowLevelFiltering, studyGroupVisibility: $studyGroupVisibility)';
  }
}
