import '../utils/date_utils.dart' as app_date_utils;

/// Study Together Response Model
class StudyTogetherResponse {
  final List<StudyActivity> studyActivities;
  final List<TrendingWord> trendingVocabulary;
  final List<ProgressUpdate> progressUpdates;
  final int totalActivities;
  final int friendsCount;
  
  StudyTogetherResponse({
    required this.studyActivities,
    required this.trendingVocabulary,
    required this.progressUpdates,
    required this.totalActivities,
    required this.friendsCount,
  });
  
  factory StudyTogetherResponse.fromJson(Map<String, dynamic> json) {
    return StudyTogetherResponse(
      studyActivities: (json['study_activities'] as List<dynamic>?)
          ?.map((e) => StudyActivity.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      trendingVocabulary: (json['trending_vocabulary'] as List<dynamic>?)
          ?.map((e) => TrendingWord.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      progressUpdates: (json['progress_updates'] as List<dynamic>?)
          ?.map((e) => ProgressUpdate.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalActivities: json['total_activities'] ?? 0,
      friendsCount: json['friends_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'study_activities': studyActivities.map((e) => e.toJson()).toList(),
      'trending_vocabulary': trendingVocabulary.map((e) => e.toJson()).toList(),
      'progress_updates': progressUpdates.map((e) => e.toJson()).toList(),
      'total_activities': totalActivities,
      'friends_count': friendsCount,
    };
  }
}

/// Trending Word Model
class TrendingWord {
  final String word;
  final String language;
  final String level;
  final int studyCount;
  final List<Studier> recentStudiers;
  final DateTime lastStudied;
  
  TrendingWord({
    required this.word,
    required this.language,
    required this.level,
    required this.studyCount,
    required this.recentStudiers,
    required this.lastStudied,
  });
  
  factory TrendingWord.fromJson(Map<String, dynamic> json) {
    return TrendingWord(
      word: json['word'] ?? '',
      language: json['language'] ?? '',
      level: json['level'] ?? '',
      studyCount: json['study_count'] ?? 0,
      recentStudiers: (json['recent_studiers'] as List<dynamic>?)
          ?.map((e) => Studier.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      lastStudied: app_date_utils.DateUtils.parseDate(json['last_studied']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'language': language,
      'level': level,
      'study_count': studyCount,
      'recent_studiers': recentStudiers.map((e) => e.toJson()).toList(),
      'last_studied': lastStudied.toIso8601String(),
    };
  }
}

/// Progress Update Model
class ProgressUpdate {
  final String type;
  final String title;
  final String description;
  final String authorName;
  final String? authorAvatar;
  final int points;
  final String icon;
  final DateTime createdAt;
  
  ProgressUpdate({
    required this.type,
    required this.title,
    required this.description,
    required this.authorName,
    this.authorAvatar,
    required this.points,
    required this.icon,
    required this.createdAt,
  });
  
  factory ProgressUpdate.fromJson(Map<String, dynamic> json) {
    return ProgressUpdate(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      authorName: json['author_name'] ?? '',
      authorAvatar: json['author_avatar'],
      points: json['points'] ?? 0,
      icon: json['icon'] ?? '🏆',
      createdAt: app_date_utils.DateUtils.parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'points': points,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Study Activity Model
class StudyActivity {
  final String type;
  final String activityType;
  final String title;
  final String content;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final String postId;
  
  StudyActivity({
    required this.type,
    required this.activityType,
    required this.title,
    required this.content,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
    required this.postId,
  });
  
  factory StudyActivity.fromJson(Map<String, dynamic> json) {
    return StudyActivity(
      type: json['type'] ?? '',
      activityType: json['activity_type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['author_name'] ?? '',
      authorAvatar: json['author_avatar'],
      createdAt: app_date_utils.DateUtils.parseDate(json['created_at']),
      postId: json['post_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'activity_type': activityType,
      'title': title,
      'content': content,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'created_at': createdAt.toIso8601String(),
      'post_id': postId,
    };
  }
}

/// Studier Model
class Studier {
  final String userName;
  final String? avatarUrl;
  final DateTime studiedAt;
  
  Studier({
    required this.userName,
    this.avatarUrl,
    required this.studiedAt,
  });
  
  factory Studier.fromJson(Map<String, dynamic> json) {
    return Studier(
      userName: json['user_name'] ?? '',
      avatarUrl: json['avatar_url'],
      studiedAt: app_date_utils.DateUtils.parseDate(json['studied_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'avatar_url': avatarUrl,
      'studied_at': studiedAt.toIso8601String(),
    };
  }
}

/// Learning Discovery Response Model
class LearningDiscoveryResponse {
  final String userName;
  final String contentType;
  final DiscoveryContent discoveryContent;
  final int totalItems;
  final int friendsCount;

  LearningDiscoveryResponse({
    required this.userName,
    required this.contentType,
    required this.discoveryContent,
    required this.totalItems,
    required this.friendsCount,
  });

  factory LearningDiscoveryResponse.fromJson(Map<String, dynamic> json) {
    return LearningDiscoveryResponse(
      userName: json['user_name'] ?? '',
      contentType: json['content_type'] ?? 'all',
      discoveryContent: DiscoveryContent.fromJson(json['discovery_content'] as Map<String, dynamic>),
      totalItems: json['total_items'] ?? 0,
      friendsCount: json['friends_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'content_type': contentType,
      'discovery_content': discoveryContent.toJson(),
      'total_items': totalItems,
      'friends_count': friendsCount,
    };
  }
}

/// Discovery Content Model
class DiscoveryContent {
  final List<VocabularyDiscovery> vocabularyDiscoveries;
  final List<ProgressInspiration> progressInspirations;
  final List<AchievementCelebration> achievementCelebrations;
  final List<StudyMotivation> studyMotivations;

  DiscoveryContent({
    required this.vocabularyDiscoveries,
    required this.progressInspirations,
    required this.achievementCelebrations,
    required this.studyMotivations,
  });

  factory DiscoveryContent.fromJson(Map<String, dynamic> json) {
    return DiscoveryContent(
      vocabularyDiscoveries: (json['vocabulary_discoveries'] as List<dynamic>?)
          ?.map((e) => VocabularyDiscovery.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      progressInspirations: (json['progress_inspirations'] as List<dynamic>?)
          ?.map((e) => ProgressInspiration.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      achievementCelebrations: (json['achievement_celebrations'] as List<dynamic>?)
          ?.map((e) => AchievementCelebration.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      studyMotivations: (json['study_motivations'] as List<dynamic>?)
          ?.map((e) => StudyMotivation.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vocabulary_discoveries': vocabularyDiscoveries.map((e) => e.toJson()).toList(),
      'progress_inspirations': progressInspirations.map((e) => e.toJson()).toList(),
      'achievement_celebrations': achievementCelebrations.map((e) => e.toJson()).toList(),
      'study_motivations': studyMotivations.map((e) => e.toJson()).toList(),
    };
  }
}

/// Vocabulary Discovery Model
class VocabularyDiscovery {
  final String vocabEntryId;
  final String word;
  final String language;
  final String level;
  final String context;
  final String authorName;
  final String? authorAvatar;
  final DateTime studiedAt;
  final String difficulty;

  VocabularyDiscovery({
    required this.vocabEntryId,
    required this.word,
    required this.language,
    required this.level,
    required this.context,
    required this.authorName,
    this.authorAvatar,
    required this.studiedAt,
    required this.difficulty,
  });

  factory VocabularyDiscovery.fromJson(Map<String, dynamic> json) {
    // Handle language field which can be either a String or List<String>
    String language = '';
    if (json['language'] != null) {
      if (json['language'] is List) {
        // If it's a list, join the languages with comma
        final languageList = json['language'] as List;
        language = languageList.map((e) => e.toString()).join(', ');
      } else {
        // If it's a string, use it directly
        language = json['language'].toString();
      }
    }

    return VocabularyDiscovery(
      vocabEntryId: json['vocab_entry_id'] ?? '',
      word: json['word'] ?? '',
      language: language,
      level: json['level'] ?? '',
      context: json['context'] ?? json['translation'] ?? '', // Use translation as context if context is not available
      authorName: json['author_name'] ?? '',
      authorAvatar: json['author_avatar'],
      studiedAt: app_date_utils.DateUtils.parseDate(json['studied_at']),
      difficulty: json['difficulty'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vocab_entry_id': vocabEntryId,
      'word': word,
      'language': language,
      'level': level,
      'context': context,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'studied_at': studiedAt.toIso8601String(),
      'difficulty': difficulty,
    };
  }
}

/// Progress Inspiration Model
class ProgressInspiration {
  final String type;
  final String title;
  final String description;
  final String authorName;
  final String? authorAvatar;
  final String achievement;
  final int streakDays;
  final int studyHours;

  ProgressInspiration({
    required this.type,
    required this.title,
    required this.description,
    required this.authorName,
    this.authorAvatar,
    required this.achievement,
    required this.streakDays,
    required this.studyHours,
  });

  factory ProgressInspiration.fromJson(Map<String, dynamic> json) {
    return ProgressInspiration(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      authorName: json['author_name'] ?? '',
      authorAvatar: json['author_avatar'],
      achievement: json['achievement'] ?? '',
      streakDays: json['streak_days'] ?? 0,
      studyHours: json['study_hours'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'achievement': achievement,
      'streak_days': streakDays,
      'study_hours': studyHours,
    };
  }
}

/// Achievement Celebration Model
class AchievementCelebration {
  final String type;
  final String title;
  final String description;
  final String authorName;
  final String? authorAvatar;
  final int points;
  final DateTime achievedAt;

  AchievementCelebration({
    required this.type,
    required this.title,
    required this.description,
    required this.authorName,
    this.authorAvatar,
    required this.points,
    required this.achievedAt,
  });

  factory AchievementCelebration.fromJson(Map<String, dynamic> json) {
    return AchievementCelebration(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      authorName: json['author_name'] ?? '',
      authorAvatar: json['author_avatar'],
      points: json['points'] ?? 0,
      achievedAt: app_date_utils.DateUtils.parseDate(json['achieved_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'points': points,
      'achieved_at': achievedAt.toIso8601String(),
    };
  }
}

/// Study Motivation Model
class StudyMotivation {
  final String type;
  final String title;
  final String content;
  final String authorName;
  final String? authorAvatar;
  final String postType;
  final DateTime createdAt;
  final String postId;

  StudyMotivation({
    required this.type,
    required this.title,
    required this.content,
    required this.authorName,
    this.authorAvatar,
    required this.postType,
    required this.createdAt,
    required this.postId,
  });

  factory StudyMotivation.fromJson(Map<String, dynamic> json) {
    return StudyMotivation(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['author_name'] ?? '',
      authorAvatar: json['author_avatar'],
      postType: json['post_type'] ?? '',
      createdAt: app_date_utils.DateUtils.parseDate(json['created_at']),
      postId: json['post_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'post_type': postType,
      'created_at': createdAt.toIso8601String(),
      'post_id': postId,
    };
  }
}
