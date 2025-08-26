class VocabularyItem {
  final String id;
  final String word;
  final String definition;
  final String translation;
  final String partOfSpeech;
  final String example;
  final String exampleTranslation;
  final String level;
  final String topicId;
  final String targetLanguage;
  final String originalLanguage;
  final DateTime createdAt;
  final bool isDuplicate;
  final String? pronunciation;
  final String category; // 'vocabulary', 'phrasal_verb', 'idiom'
  
  // User interaction fields
  final bool isFavorite;
  final bool isHidden;
  final DateTime? hiddenUntil;
  final String? personalNotes;
  final int? difficultyRating;
  final DateTime? lastReviewed;
  final int reviewCount;

  VocabularyItem({
    required this.id,
    required this.word,
    required this.definition,
    required this.translation,
    required this.partOfSpeech,
    required this.example,
    required this.exampleTranslation,
    required this.level,
    required this.topicId,
    required this.targetLanguage,
    required this.originalLanguage,
    required this.createdAt,
    required this.isDuplicate,
    this.pronunciation,
    required this.category,
    this.isFavorite = false,
    this.isHidden = false,
    this.hiddenUntil,
    this.personalNotes,
    this.difficultyRating,
    this.lastReviewed,
    this.reviewCount = 0,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      translation: json['translation'] ?? '',
      partOfSpeech: json['part_of_speech'] ?? '',
      example: json['example'] ?? '',
      exampleTranslation: json['example_translation'] ?? '',
      level: json['level'] ?? '',
      topicId: json['topic_id'] ?? '',
      targetLanguage: json['target_language'] ?? '',
      originalLanguage: json['original_language'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isDuplicate: json['is_duplicate'] ?? false,
      pronunciation: json['pronunciation'],
      category: json['category'] ?? 'vocabulary',
      isFavorite: json['is_favorite'] ?? false,
      isHidden: json['is_hidden'] ?? false,
      hiddenUntil: json['hidden_until'] != null 
          ? DateTime.parse(json['hidden_until']) 
          : null,
      personalNotes: json['personal_notes'],
      difficultyRating: json['difficulty_rating'],
      lastReviewed: json['last_reviewed'] != null 
          ? DateTime.parse(json['last_reviewed']) 
          : null,
      reviewCount: json['review_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'definition': definition,
      'translation': translation,
      'part_of_speech': partOfSpeech,
      'example': example,
      'example_translation': exampleTranslation,
      'level': level,
      'topic_id': topicId,
      'target_language': targetLanguage,
      'original_language': originalLanguage,
      'created_at': createdAt.toIso8601String(),
      'is_duplicate': isDuplicate,
      'pronunciation': pronunciation,
      'category': category,
      'is_favorite': isFavorite,
      'is_hidden': isHidden,
      'hidden_until': hiddenUntil?.toIso8601String(),
      'personal_notes': personalNotes,
      'difficulty_rating': difficultyRating,
      'last_reviewed': lastReviewed?.toIso8601String(),
      'review_count': reviewCount,
    };
  }

  VocabularyItem copyWith({
    String? id,
    String? word,
    String? definition,
    String? translation,
    String? partOfSpeech,
    String? example,
    String? exampleTranslation,
    String? level,
    String? topicId,
    String? targetLanguage,
    String? originalLanguage,
    DateTime? createdAt,
    bool? isDuplicate,
    String? pronunciation,
    String? category,
    bool? isFavorite,
    bool? isHidden,
    DateTime? hiddenUntil,
    String? personalNotes,
    int? difficultyRating,
    DateTime? lastReviewed,
    int? reviewCount,
  }) {
    return VocabularyItem(
      id: id ?? this.id,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      translation: translation ?? this.translation,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      level: level ?? this.level,
      topicId: topicId ?? this.topicId,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      createdAt: createdAt ?? this.createdAt,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      pronunciation: pronunciation ?? this.pronunciation,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      hiddenUntil: hiddenUntil ?? this.hiddenUntil,
      personalNotes: personalNotes ?? this.personalNotes,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
} 