import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/flashcard_models.dart';

class FlashcardService {
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

  static void _log(String message) {
    if (debugEnabled) {
      // ignore: avoid_print
      print('[FlashcardAPI] $message');
    }
  }

  static void _logDebug(String message) {
    if (debugEnabled) {
      // ignore: avoid_print
      print('[FlashcardAPI DEBUG] $message');
    }
  }

  static String _trimBody(String body, {int max = 800}) {
    if (body.length <= max) return body;
    return '${body.substring(0, max)}…(truncated)';
  }

  static Map<String, String> _getHeaders(String? userUuid) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (userUuid != null) {
      _log('Using user ID for authorization: $userUuid');
      headers['Authorization'] = 'Bearer $userUuid';
    }
    return headers;
  }

  // Get available study modes
  static Future<List<StudyMode>> getStudyModes() async {
    final uri = Uri.parse('$baseUrl/flashcard/study-modes');
    _log('GET $uri');
    
    try {
      final response = await http.get(uri, headers: _getHeaders(null));
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseObj = StudyModesResponse.fromJson(data);
        return responseObj.studyModes;
      } else {
        _log('Failed to get study modes, using defaults');
        return StudyMode.defaultModes;
      }
    } catch (e) {
      _log('Error getting study modes: $e');
      return StudyMode.defaultModes;
    }
  }

  // Get available session types
  static Future<List<SessionType>> getSessionTypes() async {
    final uri = Uri.parse('$baseUrl/flashcard/session-types');
    _log('GET $uri');
    
    try {
      final response = await http.get(uri, headers: _getHeaders(null));
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseObj = SessionTypesResponse.fromJson(data);
        return responseObj.sessionTypes;
      } else {
        _log('Failed to get session types, using defaults');
        return SessionType.defaultTypes;
      }
    } catch (e) {
      _log('Error getting session types: $e');
      return SessionType.defaultTypes;
    }
  }

  // Get available difficulty ratings
  static Future<List<DifficultyRating>> getDifficultyRatings() async {
    final uri = Uri.parse('$baseUrl/flashcard/difficulty-ratings');
    _log('GET $uri');
    
    try {
      final response = await http.get(uri, headers: _getHeaders(null));
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseObj = DifficultyRatingsResponse.fromJson(data);
        return responseObj.difficultyRatings;
      } else {
        _log('Failed to get difficulty ratings, using defaults');
        return DifficultyRating.defaultRatings;
      }
    } catch (e) {
      _log('Error getting difficulty ratings: $e');
      return DifficultyRating.defaultRatings;
    }
  }

  // Create a new flashcard session
  static Future<CreateSessionResponse?> createSession(
    CreateSessionRequest request,
    String userUuid,
  ) async {
    final uri = Uri.parse('$baseUrl/flashcard/session/create');
    _log('POST $uri');
    _log('Request: ${jsonEncode(request.toJson())}');
    
    try {
      final response = await http.post(
        uri,
        headers: _getHeaders(userUuid),
        body: jsonEncode(request.toJson()),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CreateSessionResponse.fromJson(data);
      } else {
        _log('Failed to create session: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _log('Error creating session: $e');
      return null;
    }
  }

  // Get current card in session
  static Future<FlashcardCard?> getCurrentCard(String sessionId, String userUuid) async {
    _logDebug('getCurrentCard called with sessionId: "$sessionId"');
    final uri = Uri.parse('$baseUrl/flashcard/session/$sessionId/current');
    
    try {
      final response = await http.get(uri, headers: _getHeaders(userUuid));

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logDebug('Parsed response data: $data');
        final responseObj = CurrentCardResponse.fromJson(data);
        _logDebug('Got current card: ${responseObj.card?.word}');
        return responseObj.card;
      } else {
        _log('Failed to get current card: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _log('Error getting current card: $e');
      return null;
    }
  }

  // Submit answer for current card
  static Future<FlashcardAnswerResult?> submitAnswer(
    String sessionId,
    FlashcardAnswer answer,
    String userUuid,
  ) async {
    _logDebug('submitAnswer called with sessionId: "$sessionId", answer: "${answer.userAnswer}"');
    final uri = Uri.parse('$baseUrl/flashcard/session/$sessionId/answer');
    _log('POST $uri');
    _log('Request body: ${jsonEncode(answer.toJson())}');
    
    try {
      final response = await http.post(
        uri,
        headers: _getHeaders(userUuid),
        body: jsonEncode(answer.toJson()),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = FlashcardAnswerResult.fromJson(data);
        _logDebug('Answer submitted successfully: correct=${result.correct}');
        return result;
      } else {
        _log('Failed to submit answer: ${response.statusCode}');
        _log('Error response body: ${response.body}');
        return null;
      }
    } catch (e) {
      _log('Error submitting answer: $e');
      return null;
    }
  }

  // Get user's flashcard statistics
  static Future<FlashcardStats?> getStats(String userUuid) async {
    final uri = Uri.parse('$baseUrl/flashcard/stats');
    _log('GET $uri');
    
    try {
      final response = await http.get(uri, headers: _getHeaders(userUuid));
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FlashcardStats.fromJson(data);
      } else {
        _log('Failed to get stats: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _log('Error getting stats: $e');
      return null;
    }
  }

  // Get flashcard analytics
  static Future<FlashcardAnalytics?> getAnalytics(String userUuid, {int days = 30}) async {
    final uri = Uri.parse('$baseUrl/flashcard/analytics?days=$days');
    _log('GET $uri');
    
    try {
      final response = await http.get(uri, headers: _getHeaders(userUuid));
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FlashcardAnalytics.fromJson(data);
      } else {
        _log('Failed to get analytics: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _log('Error getting analytics: $e');
      return null;
    }
  }

  // Get user's flashcard sessions
  static Future<List<FlashcardSession>> getSessions(String userUuid, {int limit = 50}) async {
    final uri = Uri.parse('$baseUrl/flashcard/sessions?limit=$limit');
    _log('GET $uri');
    
    try {
      final response = await http.get(uri, headers: _getHeaders(userUuid));
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseObj = SessionsListResponse.fromJson(data);
        return responseObj.sessions;
      } else {
        _log('Failed to get sessions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _log('Error getting sessions: $e');
      return [];
    }
  }

  // Delete a flashcard session
  static Future<bool> deleteSession(String sessionId, String userUuid) async {
    final uri = Uri.parse('$baseUrl/flashcard/session/$sessionId');
    _log('DELETE $uri');
    
    try {
      final response = await http.delete(uri, headers: _getHeaders(userUuid));
      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error deleting session: $e');
      return false;
    }
  }

  // Check if flashcard service is healthy
  static Future<bool> checkHealth() async {
    final uri = Uri.parse('$baseUrl/health');
    _log('GET $uri');
    
    try {
      final response = await http.get(
        uri,
        headers: _getHeaders(null),
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
          final data = jsonDecode(response.body);
          _log('Health check successful: $data');
          return true;
        } catch (jsonError) {
          _log('Warning: Health check returned non-JSON response: $jsonError');
          return true; // Consider it healthy if we get 200
        }
      }
      return false;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }

}

