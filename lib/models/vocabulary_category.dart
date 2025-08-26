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

class VocabularyListRequest {
  final int page;
  final int limit;
  final bool showFavoritesOnly;
  final bool showHidden;
  final String? topicName;
  final String? categoryName;
  final String? level;
  final String? searchTerm;

  VocabularyListRequest({
    this.page = 1,
    this.limit = 20,
    this.showFavoritesOnly = false,
    this.showHidden = false,
    this.topicName,
    this.categoryName,
    this.level,
    this.searchTerm,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'page': page,
      'limit': limit,
      'show_favorites_only': showFavoritesOnly,
      'show_hidden': showHidden,
    };

    if (topicName != null) data['topic_name'] = topicName;
    if (categoryName != null) data['category_name'] = categoryName;
    if (level != null) data['level'] = level;
    if (searchTerm != null) data['search_term'] = searchTerm;

    return data;
  }
}

class VocabularyListResponse {
  final bool success;
  final String message;
  final List<dynamic> vocabularies;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  VocabularyListResponse({
    required this.success,
    required this.message,
    required this.vocabularies,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory VocabularyListResponse.fromJson(Map<String, dynamic> json) {
    return VocabularyListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      vocabularies: json['vocabularies'] ?? [],
      totalCount: json['total_count'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      hasMore: json['has_more'] ?? false,
    );
  }
}

class VocabularyInteractionRequest {
  final String vocabEntryId;
  final String action;
  final Map<String, dynamic>? data;

  VocabularyInteractionRequest({
    required this.vocabEntryId,
    required this.action,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'vocab_entry_id': vocabEntryId,
      'action': action,
      if (data != null) ...data!,
    };
  }
}

class VocabularyPersonalList {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final int vocabCount;

  VocabularyPersonalList({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.vocabCount,
  });

  factory VocabularyPersonalList.fromJson(Map<String, dynamic> json) {
    return VocabularyPersonalList(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      vocabCount: json['vocab_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'vocab_count': vocabCount,
    };
  }
}

class CreateVocabularyListRequest {
  final String name;
  final String description;

  CreateVocabularyListRequest({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
} 