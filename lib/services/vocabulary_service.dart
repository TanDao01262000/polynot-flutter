import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/vocabulary_item.dart';
import '../models/vocabulary_request.dart';
import '../models/generate_response.dart';
import '../models/vocabulary_category.dart';

class VocabularyService {
  static String get baseUrl {
    final envUrl = dotenv.env['VOCAB_API_BASE_URL']?.trim();
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    return 'http://localhost:8001';
  }

  static bool get debugEnabled {
    final raw = (dotenv.env['VOCAB_DEBUG'] ?? '').toLowerCase();
    final envOn = raw == 'true' || raw == '1' || raw == 'yes';
    return envOn || kDebugMode;
  }

  static bool get useMockFallback {
    final raw = (dotenv.env['USE_VOCAB_MOCK'] ?? 'false').toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  static void _log(String message) {
    if (debugEnabled) {
      // ignore: avoid_print
      print('[VocabAPI] $message');
    }
  }

  static String _trimBody(String body, {int max = 800}) {
    if (body.length <= max) return body;
    return '${body.substring(0, max)}…(truncated)';
  }
  
  // Single topic generation
  static Future<GenerateResponse> generateSingleTopic(VocabularyRequest request) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/generate/single');
    _log('POST $uri');
    _log('Body: ${jsonEncode(request.toJson())}');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return GenerateResponse.fromJson(jsonDecode(response.body));
      } else {
        if (useMockFallback) {
          _log('Falling back to mock due to non-200 status');
          return _getMockResponse(request);
        }
        throw Exception('Failed to generate vocabulary: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      if (useMockFallback) {
        _log('Falling back to mock due to exception');
        return _getMockResponse(request);
      }
      rethrow;
    }
  }

  // Multiple topics generation
  static Future<GenerateResponse> generateMultipleTopics({
    required List<String> topics,
    required String level,
    required String languageToLearn,
    required String learnersNativeLanguage,
    int vocabPerBatch = 10,
    int phrasalVerbsPerBatch = 5,
    int idiomsPerBatch = 3,
    int delaySeconds = 2,
    bool saveTopicList = true,
    String? topicListName,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/generate/multiple');
    _log('POST $uri');
    _log('Body: ${jsonEncode({
      'topics': topics,
      'level': level,
      'language_to_learn': languageToLearn,
      'learners_native_language': learnersNativeLanguage,
      'vocab_per_batch': vocabPerBatch,
      'phrasal_verbs_per_batch': phrasalVerbsPerBatch,
      'idioms_per_batch': idiomsPerBatch,
      'delay_seconds': delaySeconds,
      'save_topic_list': saveTopicList,
      'topic_list_name': topicListName,
    })}');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'topics': topics,
          'level': level,
          'language_to_learn': languageToLearn,
          'learners_native_language': learnersNativeLanguage,
          'vocab_per_batch': vocabPerBatch,
          'phrasal_verbs_per_batch': phrasalVerbsPerBatch,
          'idioms_per_batch': idiomsPerBatch,
          'delay_seconds': delaySeconds,
          'save_topic_list': saveTopicList,
          'topic_list_name': topicListName,
        }),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return GenerateResponse.fromJson(jsonDecode(response.body));
      } else {
        if (useMockFallback) {
          _log('Falling back to mock due to non-200 status');
          return _getMockResponse(VocabularyRequest(
            topic: topics.join(', '),
            level: level,
            languageToLearn: languageToLearn,
            learnersNativeLanguage: learnersNativeLanguage,
            vocabPerBatch: vocabPerBatch,
            phrasalVerbsPerBatch: phrasalVerbsPerBatch,
            idiomsPerBatch: idiomsPerBatch,
          ));
        }
        throw Exception('Failed to generate vocabulary: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      if (useMockFallback) {
        _log('Falling back to mock due to exception');
        return _getMockResponse(VocabularyRequest(
          topic: topics.join(', '),
          level: level,
          languageToLearn: languageToLearn,
          learnersNativeLanguage: learnersNativeLanguage,
          vocabPerBatch: vocabPerBatch,
          phrasalVerbsPerBatch: phrasalVerbsPerBatch,
          idiomsPerBatch: idiomsPerBatch,
        ));
      }
      rethrow;
    }
  }

  // Category-based generation
  static Future<GenerateResponse> generateByCategory({
    required String category,
    required String level,
    required String languageToLearn,
    required String learnersNativeLanguage,
    int vocabPerBatch = 10,
    int phrasalVerbsPerBatch = 5,
    int idiomsPerBatch = 3,
    int delaySeconds = 2,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/generate/category');
    _log('POST $uri');
    _log('Body: ${jsonEncode({
      'category': category,
      'level': level,
      'language_to_learn': languageToLearn,
      'learners_native_language': learnersNativeLanguage,
      'vocab_per_batch': vocabPerBatch,
      'phrasal_verbs_per_batch': phrasalVerbsPerBatch,
      'idioms_per_batch': idiomsPerBatch,
      'delay_seconds': delaySeconds,
    })}');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'category': category,
          'level': level,
          'language_to_learn': languageToLearn,
          'learners_native_language': learnersNativeLanguage,
          'vocab_per_batch': vocabPerBatch,
          'phrasal_verbs_per_batch': phrasalVerbsPerBatch,
          'idioms_per_batch': idiomsPerBatch,
          'delay_seconds': delaySeconds,
        }),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return GenerateResponse.fromJson(jsonDecode(response.body));
      } else {
        if (useMockFallback) {
          _log('Falling back to mock due to non-200 status');
          return _getMockResponse(VocabularyRequest(
            topic: category,
            level: level,
            languageToLearn: languageToLearn,
            learnersNativeLanguage: learnersNativeLanguage,
            vocabPerBatch: vocabPerBatch,
            phrasalVerbsPerBatch: phrasalVerbsPerBatch,
            idiomsPerBatch: idiomsPerBatch,
            category: category,
          ));
        }
        throw Exception('Failed to generate vocabulary: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      if (useMockFallback) {
        _log('Falling back to mock due to exception');
        return _getMockResponse(VocabularyRequest(
          topic: category,
          level: level,
          languageToLearn: languageToLearn,
          learnersNativeLanguage: learnersNativeLanguage,
          vocabPerBatch: vocabPerBatch,
          phrasalVerbsPerBatch: phrasalVerbsPerBatch,
          idiomsPerBatch: idiomsPerBatch,
          category: category,
        ));
      }
      rethrow;
    }
  }

  // Get available categories
  static Future<List<String>> getCategories() async {
    final uri = Uri.parse('$baseUrl/categories');
    _log('GET $uri');
    try {
      final response = await http.get(uri);
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['categories'] ?? []);
      } else {
        throw Exception('Failed to get categories: ${response.statusCode}');
      }
    } catch (e) {
      _log('Error: $e');
      // Return mock categories for development
      return [
        'daily_life',
        'business_professional',
        'academic_education',
        'technology_digital',
        'travel_tourism',
        'health_wellness',
        'entertainment_media',
        'sports_fitness',
        'social_relationships',
        'environment_nature',
      ];
    }
  }

  // Get topics by category
  static Future<List<String>> getTopicsByCategory(String category) async {
    final uri = Uri.parse('$baseUrl/topics/$category');
    _log('GET $uri');
    try {
      final response = await http.get(uri);
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['topics'] ?? []);
      } else {
        throw Exception('Failed to get topics for category: $category (${response.statusCode})');
      }
    } catch (e) {
      _log('Error: $e');
      // Return mock topics for development
      return _getMockTopicsForCategory(category);
    }
  }

  // Mock response for development
  static GenerateResponse _getMockResponse(VocabularyRequest request) {
    final mockVocabulary = [
      VocabularyItem(
        id: 'mock-1',
        word: 'Serendipity',
        definition: 'The occurrence and development of events by chance in a happy or beneficial way',
        translation: 'sự tình cờ may mắn',
        partOfSpeech: 'noun',
        example: 'Finding this book was pure serendipity.',
        exampleTranslation: 'Việc tìm thấy cuốn sách này là một sự tình cờ may mắn.',
        level: request.level,
        topicId: 'mock-topic-1',
        targetLanguage: 'English',
        originalLanguage: 'Vietnamese',
        createdAt: DateTime.now(),
        isDuplicate: false,
        category: 'vocabulary',
      ),
      VocabularyItem(
        id: 'mock-2',
        word: 'Ubiquitous',
        definition: 'Present, appearing, or found everywhere',
        translation: 'phổ biến',
        partOfSpeech: 'adjective',
        example: 'Mobile phones have become ubiquitous in modern society.',
        exampleTranslation: 'Điện thoại di động đã trở nên phổ biến trong xã hội hiện đại.',
        level: request.level,
        topicId: 'mock-topic-1',
        targetLanguage: 'English',
        originalLanguage: 'Vietnamese',
        createdAt: DateTime.now(),
        isDuplicate: false,
        category: 'vocabulary',
      ),
      VocabularyItem(
        id: 'mock-3',
        word: 'Look up to',
        definition: 'To admire and respect someone',
        translation: 'ngưỡng mộ',
        partOfSpeech: 'phrasal verb',
        example: 'I really look up to my older sister.',
        exampleTranslation: 'Tôi thực sự ngưỡng mộ chị gái của mình.',
        level: request.level,
        topicId: 'mock-topic-1',
        targetLanguage: 'English',
        originalLanguage: 'Vietnamese',
        createdAt: DateTime.now(),
        isDuplicate: false,
        category: 'phrasal_verb',
      ),
      VocabularyItem(
        id: 'mock-4',
        word: 'Break a leg',
        definition: 'Good luck (especially in theater)',
        translation: 'chúc may mắn',
        partOfSpeech: 'idiom',
        example: 'Break a leg on your performance tonight!',
        exampleTranslation: 'Chúc may mắn với buổi biểu diễn tối nay!',
        level: request.level,
        topicId: 'mock-topic-1',
        targetLanguage: 'English',
        originalLanguage: 'Vietnamese',
        createdAt: DateTime.now(),
        isDuplicate: false,
        category: 'idiom',
      ),
    ];

    return GenerateResponse(
      success: true,
      message: 'Vocabulary generated successfully',
      method: 'single_topic',
      details: {
        'topic': request.topic,
        'level': request.level,
        'language_to_learn': request.languageToLearn,
      },
      generatedVocabulary: mockVocabulary,
      totalGenerated: mockVocabulary.length,
      newEntriesSaved: mockVocabulary.length,
      duplicatesFound: 0,
    );
  }

  // Mock topics for development
  static List<String> _getMockTopicsForCategory(String category) {
    final mockTopics = {
      'daily_life': ['family', 'food', 'shopping', 'transportation', 'home'],
      'business_professional': ['meetings', 'presentations', 'negotiations', 'emails', 'teamwork'],
      'academic_education': ['research', 'lectures', 'assignments', 'exams', 'campus'],
      'technology_digital': ['software', 'hardware', 'programming', 'social_media', 'cybersecurity'],
      'travel_tourism': ['accommodation', 'transportation', 'sightseeing', 'restaurants', 'culture'],
      'health_wellness': ['exercise', 'nutrition', 'mental_health', 'medical', 'fitness'],
      'entertainment_media': ['movies', 'music', 'books', 'games', 'celebrity'],
      'sports_fitness': ['football', 'basketball', 'tennis', 'gym', 'olympics'],
      'social_relationships': ['friendship', 'dating', 'marriage', 'networking', 'communication'],
      'environment_nature': ['climate', 'pollution', 'conservation', 'wildlife', 'sustainability'],
    };

    return mockTopics[category] ?? ['general', 'common', 'basic'];
  }

  static Future<bool> checkHealth() async {
    final uri = Uri.parse('$baseUrl/health');
    _log('GET $uri');
    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Health check timeout after 5 seconds');
        },
      );
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');
      
      if (response.statusCode == 200) {
        try {
          // Try to parse JSON response
          final data = jsonDecode(response.body);
          _log('Health check successful: $data');
          return true;
        } catch (jsonError) {
          _log('Warning: Health check returned non-JSON response: $jsonError');
          // Consider it healthy if we get 200, even without valid JSON
          return true;
        }
      }
      return false;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }

  // Get vocabulary list with pagination and filtering
  static Future<VocabularyListResponse> getVocabularyList(
    VocabularyListRequest request, {
    String? userUuid,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/vocab/list').replace(
      queryParameters: request.toJson().map((key, value) => MapEntry(key, value.toString())),
    );
    _log('GET $uri');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (userUuid != null) {
      headers['Authorization'] = userUuid;
    }
    
    try {
      final response = await http.get(uri, headers: headers);
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return VocabularyListResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get vocabulary list: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(String vocabEntryId, String userUuid) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/vocab/favorite');
    _log('POST $uri');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': userUuid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vocab_entry_id': vocabEntryId,
          'action': 'favorite',
        }),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }

  // Hide vocabulary temporarily
  static Future<bool> hideVocabulary(String vocabEntryId, String userUuid, {DateTime? hiddenUntil}) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/vocab/hide');
    _log('POST $uri');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': userUuid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vocab_entry_id': vocabEntryId,
          'action': 'hide',
          if (hiddenUntil != null) 'hidden_until': hiddenUntil.toIso8601String(),
        }),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }

  // Add personal notes
  static Future<bool> addNote(String vocabEntryId, String userUuid, String note) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/vocab/note');
    _log('POST $uri');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': userUuid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vocab_entry_id': vocabEntryId,
          'action': 'note',
          'note': note,
        }),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }

  // Rate difficulty
  static Future<bool> rateDifficulty(String vocabEntryId, String userUuid, int rating) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/vocab/rate');
    _log('POST $uri');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': userUuid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vocab_entry_id': vocabEntryId,
          'action': 'rate',
          'rating': rating,
        }),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }

  // Mark as reviewed
  static Future<bool> markAsReviewed(String vocabEntryId, String userUuid) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/vocab/review');
    _log('POST $uri');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': userUuid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vocab_entry_id': vocabEntryId,
          'action': 'review',
        }),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }

  // Create vocabulary list
  static Future<VocabularyPersonalList?> createVocabularyList(
    CreateVocabularyListRequest request,
    String userUuid,
  ) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/vocab/lists');
    _log('POST $uri');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': userUuid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VocabularyPersonalList.fromJson(data['data'] ?? {});
      }
      return null;
    } catch (e) {
      _log('Error: $e');
      return null;
    }
  }

  // Get user's vocabulary lists
  static Future<List<VocabularyPersonalList>> getVocabularyLists(String userUuid) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/vocab/lists');
    _log('GET $uri');
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': userUuid,
          'Content-Type': 'application/json',
        },
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lists = data['lists'] as List? ?? [];
        return lists.map((list) => VocabularyPersonalList.fromJson(list)).toList();
      }
      return [];
    } catch (e) {
      _log('Error: $e');
      return [];
    }
  }

  // Add vocabulary to list
  static Future<bool> addToVocabularyList(String listId, String vocabEntryId, String userUuid) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/vocab/lists/$listId/add');
    _log('POST $uri');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': userUuid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vocab_entry_id': vocabEntryId,
        }),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }

  // Remove vocabulary from list
  static Future<bool> removeFromVocabularyList(String listId, String vocabEntryId, String userUuid) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/vocab/lists/$listId/remove');
    _log('DELETE $uri');
    
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': userUuid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vocab_entry_id': vocabEntryId,
        }),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }
} 