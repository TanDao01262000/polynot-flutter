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
  
  // TTS-related fields
  final Map<String, String>? ttsAudioUrls; // version -> audio_url mapping
  final DateTime? ttsGeneratedAt;
  final bool hasTTSAudio;
  
  // User interaction fields
  final bool isFavorite;
  final bool isHidden;
  final DateTime? hiddenUntil;
  final String? personalNotes;
  final int? difficultyRating;
  final DateTime? lastReviewed;
  final int reviewCount;
  final bool isSaved;

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
    this.ttsAudioUrls,
    this.ttsGeneratedAt,
    this.hasTTSAudio = false,
    this.isFavorite = false,
    this.isHidden = false,
    this.hiddenUntil,
    this.personalNotes,
    this.difficultyRating,
    this.lastReviewed,
    this.reviewCount = 0,
    this.isSaved = false,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    // Parse TTS audio URLs
    Map<String, String>? ttsAudioUrls;
    if (json['tts_audio_urls'] != null) {
      final urlsMap = json['tts_audio_urls'] as Map<String, dynamic>;
      ttsAudioUrls = urlsMap.map((key, value) => MapEntry(key, value.toString()));
    }

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
      ttsAudioUrls: ttsAudioUrls,
      ttsGeneratedAt: json['tts_generated_at'] != null 
          ? DateTime.parse(json['tts_generated_at']) 
          : null,
      hasTTSAudio: json['has_tts_audio'] ?? false,
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
      isSaved: json['is_saved'] ?? false,
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
      'tts_audio_urls': ttsAudioUrls,
      'tts_generated_at': ttsGeneratedAt?.toIso8601String(),
      'has_tts_audio': hasTTSAudio,
      'is_favorite': isFavorite,
      'is_hidden': isHidden,
      'hidden_until': hiddenUntil?.toIso8601String(),
      'personal_notes': personalNotes,
      'difficulty_rating': difficultyRating,
      'last_reviewed': lastReviewed?.toIso8601String(),
      'review_count': reviewCount,
      'is_saved': isSaved,
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
    Map<String, String>? ttsAudioUrls,
    DateTime? ttsGeneratedAt,
    bool? hasTTSAudio,
    bool? isFavorite,
    bool? isHidden,
    DateTime? hiddenUntil,
    String? personalNotes,
    int? difficultyRating,
    DateTime? lastReviewed,
    int? reviewCount,
    bool? isSaved,
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
      ttsAudioUrls: ttsAudioUrls ?? this.ttsAudioUrls,
      ttsGeneratedAt: ttsGeneratedAt ?? this.ttsGeneratedAt,
      hasTTSAudio: hasTTSAudio ?? this.hasTTSAudio,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      hiddenUntil: hiddenUntil ?? this.hiddenUntil,
      personalNotes: personalNotes ?? this.personalNotes,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      reviewCount: reviewCount ?? this.reviewCount,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  // Special copyWith method for handling explicit null values
  VocabularyItem copyWithNull({
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
    Map<String, String>? ttsAudioUrls,
    DateTime? ttsGeneratedAt,
    bool? hasTTSAudio,
    bool? isFavorite,
    bool? isHidden,
    DateTime? hiddenUntil,
    String? personalNotes,
    int? difficultyRating,
    DateTime? lastReviewed,
    int? reviewCount,
    bool? isSaved,
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
      ttsAudioUrls: ttsAudioUrls ?? this.ttsAudioUrls,
      ttsGeneratedAt: ttsGeneratedAt ?? this.ttsGeneratedAt,
      hasTTSAudio: hasTTSAudio ?? this.hasTTSAudio,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      hiddenUntil: hiddenUntil ?? this.hiddenUntil,
      personalNotes: personalNotes ?? this.personalNotes,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      lastReviewed: lastReviewed, // Allow explicit null
      reviewCount: reviewCount ?? this.reviewCount,
      isSaved: isSaved ?? this.isSaved,
    );
  }
} 