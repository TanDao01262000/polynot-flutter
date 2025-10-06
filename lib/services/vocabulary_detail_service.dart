import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/vocabulary_item.dart';
import '../providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class VocabularyDetailService {
  static String get baseUrl {
    // Get the vocabulary API base URL from environment variables
    // This should point to the 8001 server where vocabulary details are stored
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
      print('[VocabDetailAPI] $message');
    }
  }

  // Get authenticated headers for API requests with auto token refresh
  static Future<Map<String, String>> _getAuthenticatedHeaders({UserProvider? userProvider}) async {
    try {
      _log('🔐 Attempting to get auth headers...');
      
      String? token;
      
      // Option 1: Use UserProvider for auto token refresh (PREFERRED)
      if (userProvider != null) {
        _log('🔐 Using UserProvider with auto token refresh...');
        token = await userProvider.getValidAccessToken();
        
        if (token != null) {
          _log('🔐 Got valid token from UserProvider (auto-refreshed if needed)');
          _log('🔐 Token preview: ${token.substring(0, 30)}...');
          return {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          };
        } else {
          _log('⚠️ UserProvider returned null token');
        }
      }
      
      // Option 2: Fallback to SharedPreferences (may be expired!)
      _log('🔐 Falling back to SharedPreferences (no auto-refresh)...');
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('user_session_token');
      
      _log('🔐 SharedPreferences check: ${token != null ? "FOUND" : "NULL"}');
      
      if (token != null) {
        _log('⚠️ Warning: Using token from SharedPreferences without refresh check!');
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };
        _log('🔐 Authorization header: ${headers['Authorization']!.substring(0, 30)}...');
        return headers;
      }
      
      // Option 3: Fallback to AuthService
      _log('🔐 Falling back to AuthService...');
      final headers = await AuthService.getAuthHeaders();
      _log('🔐 Auth headers retrieved from AuthService');
      
      return headers;
    } catch (e) {
      _log('🔐 Error getting auth headers: $e');
      return {
        'Content-Type': 'application/json',
      };
    }
  }

  /// Fetch vocabulary details by vocab_entry_id from the 8001 server
  /// Uses the new GET /vocab/{vocab_entry_id} endpoint
  static Future<VocabularyItem?> getVocabularyDetail(String vocabEntryId, {UserProvider? userProvider}) async {
    try {
      final uri = Uri.parse('$baseUrl/vocab/$vocabEntryId');
      
      _log('📚 Fetching vocabulary detail for ID: $vocabEntryId');
      _log('📚 URL: $uri');

      // Get authenticated headers
      final headers = await _getAuthenticatedHeaders(userProvider: userProvider);
      _log('📚 Using headers: ${headers.keys.join(", ")}');

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      _log('📚 Response: ${response.statusCode}');
      _log('📚 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['vocab_entry'] != null) {
          return VocabularyItem.fromJson(data['vocab_entry']);
        } else {
          _log('📚 Invalid response format or no vocab_entry found');
          return null;
        }
      } else if (response.statusCode == 404) {
        _log('📚 Vocabulary not found for ID: $vocabEntryId');
        return null;
      } else {
        _log('📚 Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      _log('📚 Exception: $e');
      return null;
    }
  }

  /// Fetch multiple vocabulary details by vocab_entry_ids
  static Future<List<VocabularyItem>> getVocabularyDetails(List<String> vocabEntryIds, {UserProvider? userProvider}) async {
    final List<VocabularyItem> vocabularyItems = [];
    
    for (final vocabEntryId in vocabEntryIds) {
      try {
        final vocabularyItem = await getVocabularyDetail(vocabEntryId, userProvider: userProvider);
        if (vocabularyItem != null) {
          vocabularyItems.add(vocabularyItem);
        }
      } catch (e) {
        _log('📚 Error fetching vocabulary $vocabEntryId: $e');
      }
    }
    
    return vocabularyItems;
  }

  /// Fetch multiple vocabulary details with progress callback
  static Future<List<VocabularyItem>> getVocabularyDetailsWithProgress(
    List<String> vocabEntryIds,
    Function(int current, int total) onProgress, {
    UserProvider? userProvider,
  }) async {
    final List<VocabularyItem> vocabularyItems = [];
    
    for (int i = 0; i < vocabEntryIds.length; i++) {
      final vocabEntryId = vocabEntryIds[i];
      
      try {
        // Call progress callback
        onProgress(i + 1, vocabEntryIds.length);
        
        final vocabularyItem = await getVocabularyDetail(vocabEntryId, userProvider: userProvider);
        if (vocabularyItem != null) {
          vocabularyItems.add(vocabularyItem);
        }
      } catch (e) {
        _log('📚 Error fetching vocabulary $vocabEntryId: $e');
      }
    }
    
    return vocabularyItems;
  }
}

