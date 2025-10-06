import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/study_together_models.dart';

class StudyTogetherService {
  static String get baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';
  
  /// Get Study Together content
  Future<StudyTogetherResponse> getStudyTogetherContent(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/study-together?user_id=$userId&limit=$limit');
      
      print('🎯 StudyTogetherService: Getting study together content for user: $userId');
      print('🎯 StudyTogetherService: URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🎯 StudyTogetherService: Response: ${response.statusCode}');
      print('🎯 StudyTogetherService: Body: ${response.body}');

      if (response.statusCode == 200) {
        return StudyTogetherResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load study together content: ${response.statusCode}');
      }
    } catch (e) {
      print('🎯 StudyTogetherService: Error: $e');
      rethrow;
    }
  }
  
  /// Get Learning Discovery content with optional filtering
  Future<LearningDiscoveryResponse> getLearningDiscovery(
    String userId, {
    String contentType = 'all',
    int limit = 10,
    int page = 1,
    String? levelFilter,
    List<String>? userFilter,
    String? languageFilter,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'user_id': userId,
        'content_type': contentType,
        'limit': limit.toString(),
        'page': page.toString(),
      };

      // Add optional filters
      if (levelFilter != null && levelFilter.isNotEmpty) {
        queryParams['level_filter'] = levelFilter;
      }
      
      if (userFilter != null && userFilter.isNotEmpty) {
        queryParams['user_filter'] = userFilter.join(',');
      }
      
      if (languageFilter != null && languageFilter.isNotEmpty) {
        queryParams['language_filter'] = languageFilter;
      }

      final uri = Uri.parse('$baseUrl/social/learning-discovery').replace(queryParameters: queryParams);
      
      print('🔍 Getting learning discovery for user: $userId');
      print('🔍 Filters - Level: $levelFilter, Users: $userFilter, Language: $languageFilter');
      print('🔍 URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🔍 Learning Discovery Response: ${response.statusCode}');
      print('🔍 Learning Discovery Body: ${response.body}');

      if (response.statusCode == 200) {
        return LearningDiscoveryResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load learning discovery: ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 Learning Discovery Error: $e');
      rethrow;
    }
  }
  
  /// Bookmark vocabulary word
  Future<bool> bookmarkVocabulary(
    String userId,
    String word, {
    String language = 'English',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/vocabulary/$word/bookmark?user_id=$userId&language=$language');
      
      print('🔖 Bookmarking vocabulary word: $word for user: $userId');
      print('🔖 URL: $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('🔖 Bookmark Response: ${response.statusCode}');
      print('🔖 Bookmark Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['bookmarked'] ?? false;
      } else {
        throw Exception('Failed to bookmark vocabulary: ${response.statusCode}');
      }
    } catch (e) {
      print('🔖 Bookmark Error: $e');
      rethrow;
    }
  }
}
