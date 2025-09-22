import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class TTSService {
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
      print('[TTSService] $message');
    }
  }

  static String _trimBody(String body, {int max = 800}) {
    if (body.length <= max) return body;
    return '${body.substring(0, max)}…(truncated)';
  }

  // Get authentication headers
  static Map<String, String> _getAuthHeaders(String? userToken) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (userToken != null && userToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $userToken';
    }
    
    return headers;
  }

  // 1. Generate TTS Audio
  static Future<TTSGenerateResponse> generateTTS({
    required String text,
    String? voiceId,
    String language = 'en-US',
    double speed = 1.0,
    String provider = 'google',
    String? userToken,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/generate');
    _log('POST $uri');
    
    final requestBody = {
      'text': text,
      'language': language,
      'speed': speed,
      'provider': provider,
    };
    
    if (voiceId != null) {
      requestBody['voice_id'] = voiceId;
    }
    
    _log('Body: ${jsonEncode(requestBody)}');
    
    try {
      final response = await http.post(
        uri,
        headers: _getAuthHeaders(userToken),
        body: jsonEncode(requestBody),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return TTSGenerateResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to generate TTS: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // 2. Generate TTS for Vocabulary Entry
  static Future<TTSGenerateResponse> generateTTSForVocabulary({
    required String vocabEntryId,
    String? voiceId,
    String language = 'en-US',
    String? userToken,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/generate-vocab/$vocabEntryId');
    _log('POST $uri');
    
    final queryParams = <String, String>{
      'language': language,
    };
    
    if (voiceId != null) {
      queryParams['voice_id'] = voiceId;
    }
    
    final uriWithParams = uri.replace(queryParameters: queryParams);
    _log('Final URI: $uriWithParams');
    
    try {
      final response = await http.post(
        uriWithParams,
        headers: _getAuthHeaders(userToken),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return TTSGenerateResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to generate TTS for vocabulary: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // 3. Generate Pronunciations
  static Future<TTSPronunciationGenerateResponse> generatePronunciations({
    required String vocabEntryId,
    required String text,
    String language = 'en',
    List<String> versions = const ['normal', 'slow'],
    String? voiceId,
    String? userToken,
  }) async {
    print('🔊 TTSService.generatePronunciations called');
    print('🔊 VocabEntryId: $vocabEntryId');
    print('🔊 Text: $text');
    print('🔊 UserToken: ${userToken != null ? userToken.substring(0, 20) + "..." : "NULL"}');
    print('🔊 VoiceId: $voiceId');
    print('🔊 VoiceId is null: ${voiceId == null}');
    print('🔊 VoiceId is empty: ${voiceId?.isEmpty ?? true}');
    
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/pronunciation/generate');
    _log('POST $uri');
    
    final requestBody = <String, dynamic>{
      'vocab_entry_id': vocabEntryId,
      'text': text,
      'language': language,
      'versions': versions,
    };
    
    if (voiceId != null) {
      requestBody['voice_id'] = voiceId;
      print('🔊 TTSService: Added voice_id to request body: $voiceId');
    } else {
      print('🔊 TTSService: No voice_id added to request body (voiceId is null)');
    }
    
    _log('Body: ${jsonEncode(requestBody)}');
    print('🔊 TTSService: Final request body: ${jsonEncode(requestBody)}');
    
    try {
      final response = await http.post(
        uri,
        headers: _getAuthHeaders(userToken),
        body: jsonEncode(requestBody),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('🔊 TTSService: Response data: $responseData');
        
        // Check if the response contains the expected voice_id
        if (responseData['pronunciations'] != null) {
          final pronunciations = responseData['pronunciations'];
          if (pronunciations['versions'] != null) {
            final versions = pronunciations['versions'];
            for (final versionKey in versions.keys) {
              final version = versions[versionKey];
              print('🔊 TTSService: Version $versionKey voice_id: ${version['voice_id']}');
              if (voiceId != null && version['voice_id'] != voiceId) {
                print('🔊 TTSService: WARNING - Expected voice_id: $voiceId, but got: ${version['voice_id']}');
              }
            }
          }
        }
        
        return TTSPronunciationGenerateResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to generate pronunciations: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // 4. Get Pronunciations
  static Future<TTSPronunciationResponse> getPronunciations({
    required String vocabEntryId,
    String? userToken,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/pronunciation/$vocabEntryId');
    _log('GET $uri');
    
    try {
      final response = await http.get(
        uri,
        headers: _getAuthHeaders(userToken),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return TTSPronunciationResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Pronunciations not found for vocabulary entry: $vocabEntryId');
      } else {
        throw Exception('Failed to get pronunciations: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // 5. Ensure Pronunciations Exist
  static Future<TTSPronunciationEnsureResponse> ensurePronunciations({
    required String vocabEntryId,
    List<String> versions = const ['normal', 'slow'],
    String? voiceId,
    String? userToken,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/pronunciation/ensure/$vocabEntryId');
    _log('POST $uri');
    
    final queryParams = <String, String>{
      'versions': versions.join(','),
    };
    
    if (voiceId != null) {
      queryParams['voice_id'] = voiceId;
    }
    
    final uriWithParams = uri.replace(queryParameters: queryParams);
    _log('Final URI: $uriWithParams');
    
    try {
      final response = await http.post(
        uriWithParams,
        headers: _getAuthHeaders(userToken),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return TTSPronunciationEnsureResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to ensure pronunciations: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // 6. Batch Generate Pronunciations
  static Future<TTSBatchPronunciationResponse> batchGeneratePronunciations({
    required List<String> vocabEntryIds,
    List<String> versions = const ['normal', 'slow'],
    String? voiceId,
    String? userToken,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/pronunciation/batch');
    _log('POST $uri');
    
    final requestBody = <String, dynamic>{
      'vocab_entry_ids': vocabEntryIds,
      'versions': versions,
    };
    
    if (voiceId != null) {
      requestBody['voice_id'] = voiceId;
    }
    
    _log('Body: ${jsonEncode(requestBody)}');
    
    try {
      final response = await http.post(
        uri,
        headers: _getAuthHeaders(userToken),
        body: jsonEncode(requestBody),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return TTSBatchPronunciationResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to batch generate pronunciations: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // 7. Delete Pronunciations
  static Future<bool> deletePronunciations({
    required String vocabEntryId,
    String? userToken,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/pronunciation/$vocabEntryId');
    _log('DELETE $uri');
    
    try {
      final response = await http.delete(
        uri,
        headers: _getAuthHeaders(userToken),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }

  // 8. Get Voice Profiles
  static Future<List<TTSVoiceProfile>> getVoiceProfiles({
    String? userToken,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/voice-profiles');
    _log('GET $uri');
    
    try {
      final response = await http.get(
        uri,
        headers: _getAuthHeaders(userToken),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => TTSVoiceProfile.fromJson(item)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to get voice profiles: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // 9. Delete Voice Profile
  static Future<bool> deleteVoiceProfile({
    required String voiceProfileId,
    String? userToken,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/voice-profiles/$voiceProfileId');
    _log('DELETE $uri');
    
    try {
      final response = await http.delete(
        uri,
        headers: _getAuthHeaders(userToken),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }

  // 10. Get User Subscription
  static Future<TTSSubscription> getUserSubscription({
    String? userToken,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/subscription');
    _log('GET $uri');
    
    try {
      final response = await http.get(
        uri,
        headers: _getAuthHeaders(userToken),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return TTSSubscription.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get subscription: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // 11. Get TTS Quota
  static Future<TTSQuota> getTTSQuota({
    String? userToken,
  }) async {
    _log('Base URL: $baseUrl');
    final uri = Uri.parse('$baseUrl/tts/quota');
    _log('GET $uri');
    
    try {
      final response = await http.get(
        uri,
        headers: _getAuthHeaders(userToken),
      );

      _log('Status: ${response.statusCode}');
      _log('Response: ${_trimBody(response.body)}');

      if (response.statusCode == 200) {
        return TTSQuota.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get TTS quota: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  // 12. Create Voice Clone
  static Future<TTSVoiceCloneResponse> createVoiceClone({
    required String userId,
    required String voiceName,
    required List<File> audioFiles,
    String? description,
    String? userToken,
  }) async {
    _log('🔊 TTSService: createVoiceClone called');
    _log('🔊 TTSService: Base URL: $baseUrl');
    _log('🔊 TTSService: User ID: $userId');
    _log('🔊 TTSService: Voice name: $voiceName');
    _log('🔊 TTSService: Audio files count: ${audioFiles.length}');
    _log('🔊 TTSService: Description: $description');
    _log('🔊 TTSService: User token present: ${userToken != null && userToken.isNotEmpty}');
    
    final uri = Uri.parse('$baseUrl/voice-cloning/create-voice-clone');
    _log('🔊 TTSService: POST $uri');
    
    try {
      _log('🔊 TTSService: Creating multipart request...');
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      
      _log('🔊 TTSService: Adding headers...');
      // Add headers
      if (userToken != null && userToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $userToken';
        _log('🔊 TTSService: Authorization header added');
      }
      
      _log('🔊 TTSService: Adding form fields...');
      // Add form fields
      request.fields['user_id'] = userId;
      request.fields['voice_name'] = voiceName;
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }
      _log('🔊 TTSService: Form fields added: ${request.fields}');
      
      _log('🔊 TTSService: Processing audio files...');
      // Add audio files
      for (int i = 0; i < audioFiles.length; i++) {
        final file = audioFiles[i];
        _log('🔊 TTSService: Processing file $i: ${file.path}');
        
        try {
          final exists = await file.exists();
          _log('🔊 TTSService: File $i exists: $exists');
          
          if (exists) {
            final fileLength = await file.length();
            _log('🔊 TTSService: File $i size: $fileLength bytes');
            
            final fileStream = http.ByteStream(file.openRead());
            final multipartFile = http.MultipartFile(
              'audio_files',
              fileStream,
              fileLength,
              filename: file.path.split('/').last,
            );
            request.files.add(multipartFile);
            _log('🔊 TTSService: Added audio file: ${file.path}');
          } else {
            _log('🔊 TTSService: File $i does not exist: ${file.path}');
            throw Exception('Audio file does not exist: ${file.path}');
          }
        } catch (fileError) {
          _log('🔊 TTSService: Error processing file $i: $fileError');
          rethrow;
        }
      }
      
      _log('🔊 TTSService: Sending request with ${request.files.length} audio files');
      
      // Send request
      final streamedResponse = await request.send();
      _log('🔊 TTSService: Request sent, getting response...');
      
      final response = await http.Response.fromStream(streamedResponse);
      
      _log('🔊 TTSService: Status: ${response.statusCode}');
      _log('🔊 TTSService: Response: ${_trimBody(response.body)}');
      
      if (response.statusCode == 200) {
        _log('🔊 TTSService: Success response received');
        return TTSVoiceCloneResponse.fromJson(jsonDecode(response.body));
      } else {
        _log('🔊 TTSService: Error response: ${response.statusCode} ${response.body}');
        throw Exception('Failed to create voice clone: ${response.statusCode} ${response.body}');
      }
    } catch (e, stackTrace) {
      _log('🔊 TTSService: Error in createVoiceClone: $e');
      _log('🔊 TTSService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Health check
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
      
      return response.statusCode == 200;
    } catch (e) {
      _log('Error: $e');
      return false;
    }
  }
}

// TTS Response Models
class TTSGenerateResponse {
  final bool success;
  final String audioUrl;
  final double durationSeconds;
  final int textLength;
  final String provider;

  TTSGenerateResponse({
    required this.success,
    required this.audioUrl,
    required this.durationSeconds,
    required this.textLength,
    required this.provider,
  });

  factory TTSGenerateResponse.fromJson(Map<String, dynamic> json) {
    return TTSGenerateResponse(
      success: json['success'] ?? false,
      audioUrl: json['audio_url'] ?? '',
      durationSeconds: (json['duration_seconds'] ?? 0.0).toDouble(),
      textLength: json['text_length'] ?? 0,
      provider: json['provider'] ?? '',
    );
  }
}

class TTSPronunciationGenerateResponse {
  final bool success;
  final String message;
  final List<String> generatedVersions;
  final String vocabEntryId;

  TTSPronunciationGenerateResponse({
    required this.success,
    required this.message,
    required this.generatedVersions,
    required this.vocabEntryId,
  });

  factory TTSPronunciationGenerateResponse.fromJson(Map<String, dynamic> json) {
    return TTSPronunciationGenerateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      generatedVersions: List<String>.from(json['generated_versions'] ?? []),
      vocabEntryId: json['vocab_entry_id'] ?? '',
    );
  }
}

class TTSPronunciationResponse {
  final String vocabEntryId;
  final String word;
  final Map<String, TTSPronunciationVersion> versions;

  TTSPronunciationResponse({
    required this.vocabEntryId,
    required this.word,
    required this.versions,
  });

  factory TTSPronunciationResponse.fromJson(Map<String, dynamic> json) {
    final versionsMap = <String, TTSPronunciationVersion>{};
    final versions = json['versions'] as Map<String, dynamic>? ?? {};
    
    versions.forEach((key, value) {
      versionsMap[key] = TTSPronunciationVersion.fromJson(value);
    });

    return TTSPronunciationResponse(
      vocabEntryId: json['vocab_entry_id'] ?? '',
      word: json['word'] ?? '',
      versions: versionsMap,
    );
  }
}

class TTSPronunciationVersion {
  final String audioUrl;
  final double durationSeconds;
  final String provider;
  final String voiceId;

  TTSPronunciationVersion({
    required this.audioUrl,
    required this.durationSeconds,
    required this.provider,
    required this.voiceId,
  });

  factory TTSPronunciationVersion.fromJson(Map<String, dynamic> json) {
    return TTSPronunciationVersion(
      audioUrl: json['audio_url'] ?? '',
      durationSeconds: (json['duration_seconds'] ?? 0.0).toDouble(),
      provider: json['provider'] ?? '',
      voiceId: json['voice_id'] ?? '',
    );
  }
}

class TTSPronunciationEnsureResponse {
  final bool success;
  final String message;
  final String vocabEntryId;
  final List<String> requiredVersions;

  TTSPronunciationEnsureResponse({
    required this.success,
    required this.message,
    required this.vocabEntryId,
    required this.requiredVersions,
  });

  factory TTSPronunciationEnsureResponse.fromJson(Map<String, dynamic> json) {
    return TTSPronunciationEnsureResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      vocabEntryId: json['vocab_entry_id'] ?? '',
      requiredVersions: List<String>.from(json['required_versions'] ?? []),
    );
  }
}

class TTSBatchPronunciationResponse {
  final bool success;
  final String message;
  final Map<String, TTSBatchResult> results;

  TTSBatchPronunciationResponse({
    required this.success,
    required this.message,
    required this.results,
  });

  factory TTSBatchPronunciationResponse.fromJson(Map<String, dynamic> json) {
    final resultsMap = <String, TTSBatchResult>{};
    final results = json['results'] as Map<String, dynamic>? ?? {};
    
    results.forEach((key, value) {
      resultsMap[key] = TTSBatchResult.fromJson(value);
    });

    return TTSBatchPronunciationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      results: resultsMap,
    );
  }
}

class TTSBatchResult {
  final bool success;
  final List<String>? generatedVersions;
  final String? error;

  TTSBatchResult({
    required this.success,
    this.generatedVersions,
    this.error,
  });

  factory TTSBatchResult.fromJson(Map<String, dynamic> json) {
    return TTSBatchResult(
      success: json['success'] ?? false,
      generatedVersions: json['generated_versions'] != null 
          ? List<String>.from(json['generated_versions']) 
          : null,
      error: json['error'],
    );
  }
}

class TTSVoiceProfile {
  final String id;
  final String userId;
  final String voiceName;
  final String voiceId;
  final String provider;
  final bool isActive;
  final DateTime createdAt;

  TTSVoiceProfile({
    required this.id,
    required this.userId,
    required this.voiceName,
    required this.voiceId,
    required this.provider,
    required this.isActive,
    required this.createdAt,
  });

  factory TTSVoiceProfile.fromJson(Map<String, dynamic> json) {
    return TTSVoiceProfile(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      voiceName: json['voice_name'] ?? '',
      voiceId: json['voice_id'] ?? '',
      provider: json['provider'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}

class TTSSubscription {
  final String userId;
  final String plan;
  final String status;
  final DateTime? expiresAt;
  final TTSSubscriptionFeatures features;

  TTSSubscription({
    required this.userId,
    required this.plan,
    required this.status,
    this.expiresAt,
    required this.features,
  });

  factory TTSSubscription.fromJson(Map<String, dynamic> json) {
    return TTSSubscription(
      userId: json['user_id'] ?? '',
      plan: json['plan'] ?? '',
      status: json['status'] ?? '',
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      features: TTSSubscriptionFeatures.fromJson(json['features'] ?? {}),
    );
  }
}

class TTSSubscriptionFeatures {
  final bool voiceCloning;
  final bool unlimitedTTS;
  final int customVoices;

  TTSSubscriptionFeatures({
    required this.voiceCloning,
    required this.unlimitedTTS,
    required this.customVoices,
  });

  factory TTSSubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    return TTSSubscriptionFeatures(
      voiceCloning: json['voice_cloning'] ?? false,
      unlimitedTTS: json['unlimited_tts'] ?? false,
      customVoices: json['custom_voices'] ?? 0,
    );
  }
}

class TTSQuota {
  final String userId;
  final String plan;
  final int monthlyCharacterLimit;
  final int charactersUsedThisMonth;
  final int charactersRemaining;
  final DateTime resetDate;
  final int voiceClonesLimit;
  final int voiceClonesUsed;
  final int voiceClonesRemaining;

  TTSQuota({
    required this.userId,
    required this.plan,
    required this.monthlyCharacterLimit,
    required this.charactersUsedThisMonth,
    required this.charactersRemaining,
    required this.resetDate,
    required this.voiceClonesLimit,
    required this.voiceClonesUsed,
    required this.voiceClonesRemaining,
  });

  factory TTSQuota.fromJson(Map<String, dynamic> json) {
    return TTSQuota(
      userId: json['user_id'] ?? '',
      plan: json['plan'] ?? '',
      monthlyCharacterLimit: json['monthly_character_limit'] ?? 0,
      charactersUsedThisMonth: json['characters_used_this_month'] ?? 0,
      charactersRemaining: json['characters_remaining'] ?? 0,
      resetDate: json['reset_date'] != null 
          ? DateTime.parse(json['reset_date']) 
          : DateTime.now(),
      voiceClonesLimit: json['voice_clones_limit'] ?? 0,
      voiceClonesUsed: json['voice_clones_used'] ?? 0,
      voiceClonesRemaining: json['voice_clones_remaining'] ?? 0,
    );
  }
}

class TTSVoiceCloneResponse {
  final bool success;
  final String voiceId;
  final String voiceName;
  final String status;
  final String message;

  TTSVoiceCloneResponse({
    required this.success,
    required this.voiceId,
    required this.voiceName,
    required this.status,
    required this.message,
  });

  factory TTSVoiceCloneResponse.fromJson(Map<String, dynamic> json) {
    return TTSVoiceCloneResponse(
      success: json['success'] ?? false,
      voiceId: json['voice_id'] ?? '',
      voiceName: json['voice_name'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
