import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SmartFeedService {
  static String get baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';

  /// Get personalized smart feed for a user
  static Future<Map<String, dynamic>> getSmartFeed(
    String username, {
    int page = 1,
    int limit = 20,
    bool includeTrending = true,
    bool includeLevelPeers = true,
    double personalizationScore = 0.7,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/smart-feed').replace(
        queryParameters: {
          'user_name': username,
          'page': page.toString(),
          'limit': limit.toString(),
          'include_trending': includeTrending.toString(),
          'include_level_peers': includeLevelPeers.toString(),
          'personalization_score': personalizationScore.toString(),
        },
      );

      print('🔍 Smart Feed URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🔍 Smart Feed Response: ${response.statusCode}');
      print('🔍 Smart Feed Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load smart feed: ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 Smart Feed Error: $e');
      rethrow;
    }
  }

  /// Get trending words for a specific language and level
  static Future<List<String>> getTrendingWords(
    String language,
    String level, {
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/trending-words').replace(
        queryParameters: {
          'language': language,
          'level': level,
          'limit': limit.toString(),
        },
      );

      print('📈 Trending Words URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📈 Trending Words Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['trending_words'] ?? []);
      } else {
        throw Exception('Failed to load trending words: ${response.statusCode}');
      }
    } catch (e) {
      print('📈 Trending Words Error: $e');
      // Return mock trending words for development
      return [
        'serendipity',
        'ubiquitous',
        'ephemeral',
        'resilient',
        'meticulous',
        'eloquent',
        'perseverance',
        'sophisticated',
        'innovative',
        'collaborative',
      ];
    }
  }

  /// Get personalized recommendations for a user
  static Future<Map<String, dynamic>> getPersonalizedRecommendations(
    String username, {
    int limit = 10,
    String? category,
    String? difficulty,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/recommendations').replace(
        queryParameters: {
          'user_name': username,
          'limit': limit.toString(),
          if (category != null) 'category': category,
          if (difficulty != null) 'difficulty': difficulty,
        },
      );

      print('🎯 Recommendations URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('🎯 Recommendations Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      print('🎯 Recommendations Error: $e');
      rethrow;
    }
  }

  /// Get level-based peer recommendations
  static Future<List<Map<String, dynamic>>> getLevelPeers(
    String username,
    String level, {
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/level-peers').replace(
        queryParameters: {
          'user_name': username,
          'level': level,
          'limit': limit.toString(),
        },
      );

      print('👥 Level Peers URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('👥 Level Peers Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['peers'] ?? []);
      } else {
        throw Exception('Failed to load level peers: ${response.statusCode}');
      }
    } catch (e) {
      print('👥 Level Peers Error: $e');
      rethrow;
    }
  }

  /// Record user interaction for personalization
  static Future<void> recordInteraction(
    String username,
    String contentType,
    String contentId,
    String interactionType, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/interactions');

      print('📝 Recording interaction: $interactionType for $contentType');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_name': username,
          'content_type': contentType,
          'content_id': contentId,
          'interaction_type': interactionType,
          'metadata': metadata ?? {},
        }),
      ).timeout(const Duration(seconds: 10));

      print('📝 Interaction recorded: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to record interaction: ${response.statusCode}');
      }
    } catch (e) {
      print('📝 Interaction Error: $e');
      // Don't rethrow - interaction recording is not critical
    }
  }
}
