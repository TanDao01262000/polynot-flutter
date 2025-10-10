import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StudyAnalyticsService {
  static String get baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';

  /// Record a word study session
  static Future<void> recordWordStudy(
    String username,
    String word,
    String language,
    String level,
    String studyType, {
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/study/record-word?user_name=$username');

      print('📚 Recording word study: $word ($studyType)');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'word': word,
          'language': language,
          'level': level,
          'study_type': studyType,
          'context': context ?? 'Conversation with AI partner',
          'metadata': metadata ?? {},
        }),
      ).timeout(const Duration(seconds: 10));

      print('📚 Word study recorded: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to record word study: ${response.statusCode}');
      }
    } catch (e) {
      print('📚 Word study recording error: $e');
      // Don't rethrow - study recording is not critical for app functionality
    }
  }

  /// Get study analytics for a specific language and time period
  static Future<Map<String, dynamic>> getStudyAnalytics(
    String language, {
    String? level,
    String timePeriod = 'today',
    int limit = 50,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/study/analytics').replace(
        queryParameters: {
          'language': language,
          if (level != null) 'level': level,
          'time_period': timePeriod,
          'limit': limit.toString(),
        },
      );

      print('📊 Study Analytics URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 Study Analytics Response: ${response.statusCode}');
      print('📊 Study Analytics Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load study analytics: ${response.statusCode}');
      }
    } catch (e) {
      print('📊 Study Analytics Error: $e');
      rethrow;
    }
  }

  /// Get user-specific study insights
  static Future<Map<String, dynamic>> getUserStudyInsights(String username) async {
    try {
      final uri = Uri.parse('$baseUrl/study/users/$username/insights');

      print('👤 User Study Insights URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('👤 User Study Insights Response: ${response.statusCode}');
      print('👤 User Study Insights Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user study insights: ${response.statusCode}');
      }
    } catch (e) {
      print('👤 User Study Insights Error: $e');
      rethrow;
    }
  }

  /// Record a learning session
  static Future<void> recordLearningSession(
    String username,
    String sessionType,
    String language,
    String level, {
    int durationMinutes = 0,
    int wordsStudied = 0,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/study/record-session');

      print('⏱️ Recording learning session: $sessionType');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_name': username,
          'session_type': sessionType,
          'language': language,
          'level': level,
          'duration_minutes': durationMinutes,
          'words_studied': wordsStudied,
          'metadata': metadata ?? {},
        }),
      ).timeout(const Duration(seconds: 10));

      print('⏱️ Learning session recorded: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to record learning session: ${response.statusCode}');
      }
    } catch (e) {
      print('⏱️ Learning session recording error: $e');
      // Don't rethrow - session recording is not critical
    }
  }

  /// Get study progress for a user
  static Future<Map<String, dynamic>> getStudyProgress(
    String username, {
    String? language,
    String? level,
    String timePeriod = 'week',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/study/progress/$username').replace(
        queryParameters: {
          if (language != null) 'language': language,
          if (level != null) 'level': level,
          'time_period': timePeriod,
        },
      );

      print('📈 Study Progress URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📈 Study Progress Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load study progress: ${response.statusCode}');
      }
    } catch (e) {
      print('📈 Study Progress Error: $e');
      rethrow;
    }
  }

  /// Get learning streaks and achievements
  static Future<Map<String, dynamic>> getLearningStreaks(String username) async {
    try {
      final uri = Uri.parse('$baseUrl/study/streaks/$username');

      print('🔥 Learning Streaks URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('🔥 Learning Streaks Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load learning streaks: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Learning Streaks Error: $e');
      rethrow;
    }
  }

  /// Get difficulty analysis for a user
  static Future<Map<String, dynamic>> getDifficultyAnalysis(
    String username, {
    String? language,
    String? level,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/study/difficulty/$username').replace(
        queryParameters: {
          if (language != null) 'language': language,
          if (level != null) 'level': level,
        },
      );

      print('🎯 Difficulty Analysis URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🎯 Difficulty Analysis Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load difficulty analysis: ${response.statusCode}');
      }
    } catch (e) {
      print('🎯 Difficulty Analysis Error: $e');
      rethrow;
    }
  }
}
