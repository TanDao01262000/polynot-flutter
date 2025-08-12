class VocabularyCategory {
  final String id;
  final String name;
  final String description;
  final String icon;

  const VocabularyCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  static const List<VocabularyCategory> categories = [
    VocabularyCategory(
      id: 'vocabulary',
      name: 'Vocabulary',
      description: 'General vocabulary words',
      icon: '📚',
    ),
    VocabularyCategory(
      id: 'phrasal_verbs',
      name: 'Phrasal Verbs',
      description: 'Common phrasal verbs',
      icon: '🔗',
    ),
    VocabularyCategory(
      id: 'idioms',
      name: 'Idioms',
      description: 'Popular idioms and expressions',
      icon: '💡',
    ),
    VocabularyCategory(
      id: 'collocations',
      name: 'Collocations',
      description: 'Word combinations that sound natural',
      icon: '🎯',
    ),
  ];
} 