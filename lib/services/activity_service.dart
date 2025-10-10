import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ActivityService {
  static const String _baseUrl = 'http://localhost:8000';

  /// Record a user activity for streak tracking
  /// 
  /// Activity types:
  /// - 'vocabulary_study': User studied vocabulary words
  /// - 'conversation_message': User sent a message in conversation
  /// - 'social_post': User created a social post
  /// - 'achievement_unlock': User unlocked an achievement
  /// - 'flashcard_review': User reviewed flashcards
  /// - 'grammar_practice': User practiced grammar
  /// - 'reading_practice': User did reading practice
  /// 
  /// Returns true if activity was recorded successfully
  static Future<bool> recordActivity({
    required String userId,
    required String activityType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('🎯 ActivityService: Recording activity - $activityType for $userId');
      
      // Get auth headers
      final headers = await _getAuthenticatedHeaders();
      
      // Prepare the request body
      final body = {
        'activity_type': activityType,
        if (metadata != null) 'metadata': metadata,
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/users/$userId/activity'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      print('📊 ActivityService: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ ActivityService: Activity recorded successfully');
        print('📈 ActivityService: Current streak: ${responseData['current_streak']} days');
        print('🔥 ActivityService: Streak extended: ${responseData['streak_extended']}');
        return true;
      } else {
        print('❌ ActivityService: Failed to record activity - ${response.statusCode}');
        print('❌ ActivityService: Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 ActivityService: Error recording activity: $e');
      return false;
    }
  }

  /// Get current streak information for a user
  static Future<Map<String, dynamic>?> getStreakInfo(String userId) async {
    try {
      print('📊 ActivityService: Getting streak info for $userId');
      
      final headers = await _getAuthenticatedHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/streak'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ ActivityService: Streak info retrieved');
        print('📈 ActivityService: Current streak: ${responseData['current_streak']} days');
        print('📅 ActivityService: Last activity: ${responseData['last_activity_date']}');
        return responseData;
      } else {
        print('❌ ActivityService: Failed to get streak info - ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 ActivityService: Error getting streak info: $e');
      return null;
    }
  }

  /// Get authenticated headers for API requests
  static Future<Map<String, String>> _getAuthenticatedHeaders() async {
    try {
      // Try to get token from SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('access_token');
      
      // If no token or token is expired, try to get from auth headers
      if (accessToken == null || accessToken.isEmpty) {
        print('🔄 ActivityService: No access token, attempting to get auth headers...');
        final authHeaders = await AuthService.getAuthHeaders();
        accessToken = authHeaders['Authorization']?.replaceFirst('Bearer ', '');
      }
      
      if (accessToken != null && accessToken.isNotEmpty) {
        return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        };
      } else {
        print('⚠️ ActivityService: No valid access token available');
        return {
          'Content-Type': 'application/json',
        };
      }
    } catch (e) {
      print('💥 ActivityService: Error getting auth headers: $e');
      return {
        'Content-Type': 'application/json',
      };
    }
  }

  /// Helper method to record vocabulary study activity
  static Future<bool> recordVocabularyStudy({
    required String userId,
    int? wordsStudied,
    String? vocabularyList,
  }) async {
    return await recordActivity(
      userId: userId,
      activityType: 'vocabulary_study',
      metadata: {
        if (wordsStudied != null) 'words_studied': wordsStudied,
        if (vocabularyList != null) 'vocabulary_list': vocabularyList,
      },
    );
  }

  /// Helper method to record conversation activity
  static Future<bool> recordConversationMessage({
    required String userId,
    String? partnerName,
    int? messageLength,
  }) async {
    return await recordActivity(
      userId: userId,
      activityType: 'conversation_message',
      metadata: {
        if (partnerName != null) 'partner_name': partnerName,
        if (messageLength != null) 'message_length': messageLength,
      },
    );
  }

  /// Helper method to record social post activity
  static Future<bool> recordSocialPost({
    required String userId,
    String? postType,
    int? wordCount,
  }) async {
    return await recordActivity(
      userId: userId,
      activityType: 'social_post',
      metadata: {
        if (postType != null) 'post_type': postType,
        if (wordCount != null) 'word_count': wordCount,
      },
    );
  }
}
