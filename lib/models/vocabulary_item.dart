class VocabularyItem {
  final String word;
  final String definition;
  final String partOfSpeech;
  final String example;
  final String exampleTranslation;
  final String level;
  final bool isDuplicate;
  final String? pronunciation;
  final String category; // 'vocabulary', 'phrasal_verb', 'idiom'

  VocabularyItem({
    required this.word,
    required this.definition,
    required this.partOfSpeech,
    required this.example,
    required this.exampleTranslation,
    required this.level,
    required this.isDuplicate,
    this.pronunciation,
    required this.category,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      partOfSpeech: json['part_of_speech'] ?? '',
      example: json['example'] ?? '',
      exampleTranslation: json['example_translation'] ?? '',
      level: json['level'] ?? '',
      isDuplicate: json['is_duplicate'] ?? false,
      pronunciation: json['pronunciation'],
      category: json['category'] ?? 'vocabulary',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'definition': definition,
      'part_of_speech': partOfSpeech,
      'example': example,
      'example_translation': exampleTranslation,
      'level': level,
      'is_duplicate': isDuplicate,
      'pronunciation': pronunciation,
      'category': category,
    };
  }
} 