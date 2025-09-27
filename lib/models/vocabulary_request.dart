class VocabularyRequest {
  final String topic;
  final String level; // 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'
  final String languageToLearn; // 'english', 'spanish', 'french', etc.
  final String learnersNativeLanguage; // 'vietnamese', 'english', etc.
  final int vocabPerBatch;
  final int phrasalVerbsPerBatch;
  final int idiomsPerBatch;
  final int delaySeconds;
  final bool saveTopicList;
  final String? topicListName;
  final String? category; // For category-based generation

  VocabularyRequest({
    required this.topic,
    required this.level,
    required this.languageToLearn,
    required this.learnersNativeLanguage,
    this.vocabPerBatch = 10,
    this.phrasalVerbsPerBatch = 5,
    this.idiomsPerBatch = 3,
    this.delaySeconds = 2,
    this.saveTopicList = true,
    this.topicListName,
    this.category,
  });

  // Helper method to capitalize language names to match backend format
  String _capitalizeLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return 'English';
      case 'spanish':
        return 'Spanish';
      case 'french':
        return 'French';
      case 'german':
        return 'German';
      case 'italian':
        return 'Italian';
      case 'chinese':
        return 'Chinese';
      case 'japanese':
        return 'Japanese';
      case 'korean':
        return 'Korean';
      case 'vietnamese':
        return 'Vietnamese';
      default:
        // Fallback: capitalize first letter
        return language.isEmpty ? language : language[0].toUpperCase() + language.substring(1).toLowerCase();
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'topic': topic,
      'level': level,
      'language_to_learn': _capitalizeLanguage(languageToLearn),
      'learners_native_language': _capitalizeLanguage(learnersNativeLanguage),
      'vocab_per_batch': vocabPerBatch,
      'phrasal_verbs_per_batch': phrasalVerbsPerBatch,
      'idioms_per_batch': idiomsPerBatch,
      'delay_seconds': delaySeconds,
      'save_topic_list': saveTopicList,
    };

    // Only include topic_list_name if saving is enabled, otherwise explicitly set to null
    if (saveTopicList) {
      final effectiveName = (topicListName == null || topicListName!.trim().isEmpty)
          ? topic
          : topicListName!.trim();
      json['topic_list_name'] = effectiveName;
    } else {
      json['topic_list_name'] = null;
    }

    if (category != null) {
      json['category'] = category;
    }

    return json;
  }

  factory VocabularyRequest.fromJson(Map<String, dynamic> json) {
    return VocabularyRequest(
      topic: json['topic'] ?? '',
      level: json['level'] ?? '',
      languageToLearn: json['language_to_learn'] ?? '',
      learnersNativeLanguage: json['learners_native_language'] ?? '',
      vocabPerBatch: json['vocab_per_batch'] ?? 10,
      phrasalVerbsPerBatch: json['phrasal_verbs_per_batch'] ?? 5,
      idiomsPerBatch: json['idioms_per_batch'] ?? 3,
      delaySeconds: json['delay_seconds'] ?? 2,
      saveTopicList: json['save_topic_list'] ?? true,
      topicListName: json['topic_list_name'],
      category: json['category'],
    );
  }
} 