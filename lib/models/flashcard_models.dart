// Flashcard system models based on backend API documentation

class StudyMode {
  final String value;
  final String name;
  final String description;

  const StudyMode({
    required this.value,
    required this.name,
    required this.description,
  });

  factory StudyMode.fromJson(Map<String, dynamic> json) {
    return StudyMode(
      value: json['value'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'name': name,
      'description': description,
    };
  }

  static const List<StudyMode> defaultModes = [
    StudyMode(
      value: 'practice',
      name: 'Practice Mode',
      description: 'Show word, guess the definition',
    ),
    StudyMode(
      value: 'review',
      name: 'Review Mode',
      description: 'Show definition, guess the word',
    ),
  ];
}

class SessionType {
  final String value;
  final String name;
  final String description;

  const SessionType({
    required this.value,
    required this.name,
    required this.description,
  });

  factory SessionType.fromJson(Map<String, dynamic> json) {
    return SessionType(
      value: json['value'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'name': name,
      'description': description,
    };
  }

  static const List<SessionType> defaultTypes = [
    SessionType(
      value: 'daily_review',
      name: 'Daily Review',
      description: 'Review overdue and new cards',
    ),
    SessionType(
      value: 'topic_focus',
      name: 'Topic Focus',
      description: 'Focus on specific topic vocabulary',
    ),
    SessionType(
      value: 'level_progression',
      name: 'Level Progression',
      description: 'Progressive difficulty levels',
    ),
  ];
}

class DifficultyRating {
  final String value;
  final String name;
  final String description;

  const DifficultyRating({
    required this.value,
    required this.name,
    required this.description,
  });

  factory DifficultyRating.fromJson(Map<String, dynamic> json) {
    return DifficultyRating(
      value: json['value'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'name': name,
      'description': description,
    };
  }

  static const List<DifficultyRating> defaultRatings = [
    DifficultyRating(
      value: 'easy',
      name: 'Easy',
      description: 'I knew this well',
    ),
    DifficultyRating(
      value: 'medium',
      name: 'Medium',
      description: 'I knew this but took some time',
    ),
    DifficultyRating(
      value: 'hard',
      name: 'Hard',
      description: 'I struggled with this',
    ),
    DifficultyRating(
      value: 'again',
      name: 'Again',
      description: 'I need to review this again soon',
    ),
  ];
}

class FlashcardSession {
  final String id;
  final String sessionName;
  final String sessionType;
  final String studyMode;
  final String? topicName;
  final String? categoryName;
  final String? level;
  final int maxCards;
  final int? timeLimitMinutes;
  final bool includeReviewed;
  final bool includeFavorites;
  final bool smartSelection;
  final int totalCards;
  final DateTime createdAt;
  final bool isActive;

  const FlashcardSession({
    required this.id,
    required this.sessionName,
    required this.sessionType,
    required this.studyMode,
    this.topicName,
    this.categoryName,
    this.level,
    required this.maxCards,
    this.timeLimitMinutes,
    required this.includeReviewed,
    required this.includeFavorites,
    required this.smartSelection,
    required this.totalCards,
    required this.createdAt,
    required this.isActive,
  });

  factory FlashcardSession.fromJson(Map<String, dynamic> json) {
    return FlashcardSession(
      id: json['session_id'] ?? json['id'] ?? '',
      sessionName: json['session_name'] ?? '',
      sessionType: json['session_type'] ?? '',
      studyMode: json['study_mode'] ?? '',
      topicName: json['topic_name'],
      categoryName: json['category_name'],
      level: json['level'],
      maxCards: json['max_cards'] ?? 0,
      timeLimitMinutes: json['time_limit_minutes'],
      includeReviewed: json['include_reviewed'] ?? false,
      includeFavorites: json['include_favorites'] ?? false,
      smartSelection: json['smart_selection'] ?? false,
      totalCards: json['total_cards'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': id,
      'session_name': sessionName,
      'session_type': sessionType,
      'study_mode': studyMode,
      'topic_name': topicName,
      'category_name': categoryName,
      'level': level,
      'max_cards': maxCards,
      'time_limit_minutes': timeLimitMinutes,
      'include_reviewed': includeReviewed,
      'include_favorites': includeFavorites,
      'smart_selection': smartSelection,
      'total_cards': totalCards,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  FlashcardSession copyWith({
    String? id,
    String? sessionName,
    String? sessionType,
    String? studyMode,
    String? topicName,
    String? categoryName,
    String? level,
    int? maxCards,
    int? timeLimitMinutes,
    bool? includeReviewed,
    bool? includeFavorites,
    bool? smartSelection,
    int? totalCards,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return FlashcardSession(
      id: id ?? this.id,
      sessionName: sessionName ?? this.sessionName,
      sessionType: sessionType ?? this.sessionType,
      studyMode: studyMode ?? this.studyMode,
      topicName: topicName ?? this.topicName,
      categoryName: categoryName ?? this.categoryName,
      level: level ?? this.level,
      maxCards: maxCards ?? this.maxCards,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      includeReviewed: includeReviewed ?? this.includeReviewed,
      includeFavorites: includeFavorites ?? this.includeFavorites,
      smartSelection: smartSelection ?? this.smartSelection,
      totalCards: totalCards ?? this.totalCards,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class FlashcardCard {
  final String vocabEntryId;
  final String word;
  final String definition;
  final String translation;
  final String example;
  final String exampleTranslation;
  final String partOfSpeech;
  final String level;
  final int cardIndex;
  final int totalCards;

  const FlashcardCard({
    required this.vocabEntryId,
    required this.word,
    required this.definition,
    required this.translation,
    required this.example,
    required this.exampleTranslation,
    required this.partOfSpeech,
    required this.level,
    required this.cardIndex,
    required this.totalCards,
  });

  factory FlashcardCard.fromJson(Map<String, dynamic> json) {
    return FlashcardCard(
      vocabEntryId: json['vocab_entry_id'] ?? '',
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      translation: json['translation'] ?? '',
      example: json['example'] ?? '',
      exampleTranslation: json['example_translation'] ?? '',
      partOfSpeech: json['part_of_speech'] ?? '',
      level: json['level'] ?? '',
      cardIndex: json['card_index'] ?? 0,
      totalCards: json['total_cards'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vocab_entry_id': vocabEntryId,
      'word': word,
      'definition': definition,
      'translation': translation,
      'example': example,
      'example_translation': exampleTranslation,
      'part_of_speech': partOfSpeech,
      'level': level,
      'card_index': cardIndex,
      'total_cards': totalCards,
    };
  }
}

class FlashcardAnswer {
  final String userAnswer;
  final double responseTimeSeconds;
  final int hintsUsed;
  final String? difficultyRating;

  const FlashcardAnswer({
    required this.userAnswer,
    required this.responseTimeSeconds,
    required this.hintsUsed,
    this.difficultyRating,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_answer': userAnswer,
      'response_time_seconds': responseTimeSeconds,
      'hints_used': hintsUsed,
      if (difficultyRating != null) 'difficulty_rating': difficultyRating,
    };
  }
}

class FlashcardAnswerResult {
  final bool success;
  final bool correct;
  final double confidenceScore;
  final bool sessionComplete;
  final bool nextCardAvailable;
  final SessionStats sessionStats;
  final String? feedback;

  const FlashcardAnswerResult({
    required this.success,
    required this.correct,
    required this.confidenceScore,
    required this.sessionComplete,
    required this.nextCardAvailable,
    required this.sessionStats,
    this.feedback,
  });

  factory FlashcardAnswerResult.fromJson(Map<String, dynamic> json) {
    // Handle both old and new response formats
    final result = json['result'] ?? json;
    
    return FlashcardAnswerResult(
      success: json['success'] ?? false,
      correct: result['is_correct'] ?? result['correct'] ?? false,
      confidenceScore: (result['confidence_score'] ?? 0.0).toDouble(),
      sessionComplete: result['session_complete'] ?? false,
      nextCardAvailable: result['next_card_available'] ?? false,
      sessionStats: SessionStats.fromJson(result['progress'] ?? result['session_stats'] ?? {}),
      feedback: result['feedback'],
    );
  }
}

class SessionStats {
  final int correctAnswers;
  final int incorrectAnswers;
  final int cardsRemaining;

  const SessionStats({
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.cardsRemaining,
  });

  factory SessionStats.fromJson(Map<String, dynamic> json) {
    final totalCards = json['total_cards'] ?? 0;
    final currentCard = json['current_card'] ?? 0;
    final cardsRemaining = totalCards - currentCard;
    
    return SessionStats(
      correctAnswers: json['correct_answers'] ?? 0,
      incorrectAnswers: json['incorrect_answers'] ?? 0,
      cardsRemaining: cardsRemaining,
    );
  }

  int get totalAnswered => correctAnswers + incorrectAnswers;
  double get accuracyPercentage => totalAnswered > 0 ? (correctAnswers / totalAnswered) * 100 : 0.0;
}

class FlashcardStats {
  final int totalSessions;
  final int cardsStudied;
  final double accuracyPercentage;
  final int currentStreak;
  final int longestStreak;
  final String favoriteStudyMode;
  final double averageSessionDuration;

  const FlashcardStats({
    required this.totalSessions,
    required this.cardsStudied,
    required this.accuracyPercentage,
    required this.currentStreak,
    required this.longestStreak,
    required this.favoriteStudyMode,
    required this.averageSessionDuration,
  });

  factory FlashcardStats.fromJson(Map<String, dynamic> json) {
    return FlashcardStats(
      totalSessions: json['total_sessions'] ?? 0,
      cardsStudied: json['cards_studied'] ?? 0,
      accuracyPercentage: (json['accuracy_percentage'] ?? 0.0).toDouble(),
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      favoriteStudyMode: json['favorite_study_mode'] ?? '',
      averageSessionDuration: (json['average_session_duration'] ?? 0.0).toDouble(),
    );
  }
}

class FlashcardAnalytics {
  final int periodDays;
  final int totalSessions;
  final int cardsStudied;
  final double accuracyPercentage;
  final String improvementTrend;
  final double studyTimeMinutes;
  final List<String> mostStudiedTopics;
  final Map<String, int> difficultyBreakdown;
  final int? correctAnswers;
  final int? incorrectAnswers;
  final double? averageResponseTime;
  final Map<String, int>? studyModeDistribution;
  final Map<String, int>? timeDistribution;
  final Map<String, dynamic>? dailyPerformance;
  final List<String>? recommendations;

  const FlashcardAnalytics({
    required this.periodDays,
    required this.totalSessions,
    required this.cardsStudied,
    required this.accuracyPercentage,
    required this.improvementTrend,
    required this.studyTimeMinutes,
    required this.mostStudiedTopics,
    required this.difficultyBreakdown,
    this.correctAnswers,
    this.incorrectAnswers,
    this.averageResponseTime,
    this.studyModeDistribution,
    this.timeDistribution,
    this.dailyPerformance,
    this.recommendations,
  });

  factory FlashcardAnalytics.fromJson(Map<String, dynamic> json) {
    // Debug the full JSON first
    print('DEBUG: Full JSON response: $json');
    
    // Handle nested analytics object
    final analytics = json['analytics'] ?? json;
    
    // Debug logging
    print('DEBUG: Full analytics object: $analytics');
    print('DEBUG: correct_answers = ${analytics['correct_answers']}');
    print('DEBUG: incorrect_answers = ${analytics['incorrect_answers']}');
    print('DEBUG: average_response_time = ${analytics['average_response_time']}');
    print('DEBUG: total_cards_studied = ${analytics['total_cards_studied']}');
    
    return FlashcardAnalytics(
      periodDays: analytics['period_days'] ?? 0,
      totalSessions: analytics['total_sessions'] ?? 0,
      cardsStudied: analytics['total_cards_studied'] ?? 0,
      accuracyPercentage: (analytics['accuracy_percentage'] ?? 0.0).toDouble(),
      improvementTrend: analytics['improvement_trend'] ?? 'stable',
      studyTimeMinutes: _calculateStudyTime(analytics),
      mostStudiedTopics: List<String>.from(analytics['most_studied_topics'] ?? []),
      difficultyBreakdown: Map<String, int>.from(analytics['difficulty_breakdown'] ?? {}),
      correctAnswers: (analytics['correct_answers'] ?? 0) as int,
      incorrectAnswers: (analytics['incorrect_answers'] ?? 0) as int,
      averageResponseTime: (analytics['average_response_time'] ?? 0.0).toDouble(),
      studyModeDistribution: analytics['study_mode_distribution'] != null 
          ? Map<String, int>.from(analytics['study_mode_distribution'])
          : null,
      timeDistribution: analytics['time_distribution'] != null
          ? Map<String, int>.from(analytics['time_distribution'])
          : null,
      dailyPerformance: analytics['daily_performance'],
      recommendations: analytics['recommendations'] != null
          ? List<String>.from(analytics['recommendations'])
          : null,
    );
  }

  static double _calculateStudyTime(Map<String, dynamic> analytics) {
    final totalCards = analytics['total_cards_studied'] ?? 0;
    final avgResponseTime = analytics['average_response_time'] ?? 0.0;
    
    // Calculate total study time: total cards * average response time per card
    // Convert from seconds to minutes
    return (totalCards * avgResponseTime) / 60.0;
  }
}

class CreateSessionRequest {
  final String sessionName;
  final String sessionType;
  final String studyMode;
  final String? topicName;
  final String? categoryName;
  final String? level;
  final int maxCards;
  final int? timeLimitMinutes;
  final bool includeReviewed;
  final bool includeFavorites;
  final bool smartSelection;

  const CreateSessionRequest({
    required this.sessionName,
    required this.sessionType,
    required this.studyMode,
    this.topicName,
    this.categoryName,
    this.level,
    required this.maxCards,
    this.timeLimitMinutes,
    required this.includeReviewed,
    required this.includeFavorites,
    required this.smartSelection,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_name': sessionName,
      'session_type': sessionType,
      'study_mode': studyMode,
      'topic_name': topicName,
      'category_name': categoryName,
      'level': level,
      'max_cards': maxCards,
      'time_limit_minutes': timeLimitMinutes,
      'include_reviewed': includeReviewed,
      'include_favorites': includeFavorites,
      'smart_selection': smartSelection,
    };
  }
}

class CreateSessionResponse {
  final bool success;
  final String sessionId;
  final String sessionName;
  final int totalCards;
  final String studyMode;
  final String sessionType;
  final FlashcardCard? currentCard;

  const CreateSessionResponse({
    required this.success,
    required this.sessionId,
    required this.sessionName,
    required this.totalCards,
    required this.studyMode,
    required this.sessionType,
    this.currentCard,
  });

  factory CreateSessionResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested session structure from backend
    final sessionData = json['session'] ?? json;
    final currentCardData = json['current_card'];
    
    return CreateSessionResponse(
      success: json['success'] ?? false,
      sessionId: sessionData['id'] ?? sessionData['session_id'] ?? '',
      sessionName: sessionData['session_name'] ?? '',
      totalCards: sessionData['total_cards'] ?? 0,
      studyMode: sessionData['study_mode'] ?? '',
      sessionType: sessionData['session_type'] ?? '',
      currentCard: currentCardData != null 
          ? FlashcardCard.fromJson(currentCardData) 
          : null,
    );
  }
}

class StudyModesResponse {
  final bool success;
  final List<StudyMode> studyModes;

  const StudyModesResponse({
    required this.success,
    required this.studyModes,
  });

  factory StudyModesResponse.fromJson(Map<String, dynamic> json) {
    return StudyModesResponse(
      success: json['success'] ?? false,
      studyModes: (json['study_modes'] as List?)
          ?.map((mode) => StudyMode.fromJson(mode))
          .toList() ?? [],
    );
  }
}

class SessionTypesResponse {
  final bool success;
  final List<SessionType> sessionTypes;

  const SessionTypesResponse({
    required this.success,
    required this.sessionTypes,
  });

  factory SessionTypesResponse.fromJson(Map<String, dynamic> json) {
    return SessionTypesResponse(
      success: json['success'] ?? false,
      sessionTypes: (json['session_types'] as List?)
          ?.map((type) => SessionType.fromJson(type))
          .toList() ?? [],
    );
  }
}

class DifficultyRatingsResponse {
  final bool success;
  final List<DifficultyRating> difficultyRatings;

  const DifficultyRatingsResponse({
    required this.success,
    required this.difficultyRatings,
  });

  factory DifficultyRatingsResponse.fromJson(Map<String, dynamic> json) {
    return DifficultyRatingsResponse(
      success: json['success'] ?? false,
      difficultyRatings: (json['difficulty_ratings'] as List?)
          ?.map((rating) => DifficultyRating.fromJson(rating))
          .toList() ?? [],
    );
  }
}

class CurrentCardResponse {
  final bool success;
  final FlashcardCard? card;

  const CurrentCardResponse({
    required this.success,
    this.card,
  });

  factory CurrentCardResponse.fromJson(Map<String, dynamic> json) {
    return CurrentCardResponse(
      success: json['success'] ?? false,
      card: json['current_card'] != null ? FlashcardCard.fromJson(json['current_card']) : null,
    );
  }
}

class SessionsListResponse {
  final bool success;
  final List<FlashcardSession> sessions;

  const SessionsListResponse({
    required this.success,
    required this.sessions,
  });

  factory SessionsListResponse.fromJson(Map<String, dynamic> json) {
    return SessionsListResponse(
      success: json['success'] ?? false,
      sessions: (json['sessions'] as List?)
          ?.map((session) => FlashcardSession.fromJson(session))
          .toList() ?? [],
    );
  }
}

// Helper class to parse enhanced feedback
class FeedbackContent {
  final String reasoning;
  final String? learningTip;
  final String? encouragement;

  const FeedbackContent({
    required this.reasoning,
    this.learningTip,
    this.encouragement,
  });

  factory FeedbackContent.fromFeedback(String? feedback) {
    if (feedback == null || feedback.isEmpty) {
      return const FeedbackContent(reasoning: '');
    }

    // Split feedback by the emoji markers
    final parts = feedback.split('\n\n');
    String reasoning = '';
    String? learningTip;
    String? encouragement;

    for (final part in parts) {
      final trimmedPart = part.trim();
      if (trimmedPart.startsWith('💡 Learning Tip:')) {
        learningTip = trimmedPart.replaceFirst('💡 Learning Tip:', '').trim();
      } else if (trimmedPart.startsWith('🌟')) {
        encouragement = trimmedPart.replaceFirst('🌟', '').trim();
      } else if (trimmedPart.isNotEmpty && !trimmedPart.startsWith('💡') && !trimmedPart.startsWith('🌟')) {
        // This is the reasoning part
        reasoning = trimmedPart;
      }
    }

    return FeedbackContent(
      reasoning: reasoning,
      learningTip: learningTip,
      encouragement: encouragement,
    );
  }
}

