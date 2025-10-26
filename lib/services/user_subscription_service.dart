import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserSubscriptionService {
  static String get _baseUrl {
    final envUrl = dotenv.env['VOCAB_API_BASE_URL']?.trim();
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    return 'http://localhost:8001';
  }

  // Get user's subscription information
  static Future<UserSubscriptionResponse> getUserSubscription(String userToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tts/subscription'),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
      );

      print('[UserSubscriptionService] GET $_baseUrl/tts/subscription');
      print('[UserSubscriptionService] Status: ${response.statusCode}');
      print('[UserSubscriptionService] Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserSubscriptionResponse.fromJson(data);
      } else {
        throw Exception('Failed to get user subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('[UserSubscriptionService] Error: $e');
      rethrow;
    }
  }

  // Get user's TTS usage quota information
  static Future<UserQuotaResponse> getUserQuota(String userToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tts/quota'),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
      );

      print('[UserSubscriptionService] GET $_baseUrl/tts/quota');
      print('[UserSubscriptionService] Status: ${response.statusCode}');
      print('[UserSubscriptionService] Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserQuotaResponse.fromJson(data);
      } else {
        throw Exception('Failed to get user quota: ${response.statusCode}');
      }
    } catch (e) {
      print('[UserSubscriptionService] Error: $e');
      rethrow;
    }
  }
}

// User Subscription Response Model
class UserSubscriptionResponse {
  final String userId;
  final String plan;
  final String status;
  final DateTime? expiresAt;
  final UserSubscriptionFeatures features;

  UserSubscriptionResponse({
    required this.userId,
    required this.plan,
    required this.status,
    this.expiresAt,
    required this.features,
  });

  factory UserSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    // Handle both 'status' and 'is_active' fields from backend
    String status = 'inactive';
    if (json['status'] != null) {
      status = json['status'];
    } else if (json['is_active'] != null) {
      status = json['is_active'] == true ? 'active' : 'inactive';
    }
    
    return UserSubscriptionResponse(
      userId: json['user_id'] ?? '',
      plan: json['plan'] ?? 'free',
      status: status,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      features: UserSubscriptionFeatures.fromJson(json['features'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'plan': plan,
      'status': status,
      'expires_at': expiresAt?.toIso8601String(),
      'features': features.toJson(),
    };
  }

  bool get isActive => status == 'active';
  bool get isPremium => plan == 'premium';
  bool get isFree => plan == 'free';
}

// User Subscription Features Model
class UserSubscriptionFeatures {
  final bool voiceCloning;
  final bool unlimitedTts;
  final bool customVoices;
  final bool highQualityAudio;

  UserSubscriptionFeatures({
    required this.voiceCloning,
    required this.unlimitedTts,
    required this.customVoices,
    required this.highQualityAudio,
  });

  factory UserSubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionFeatures(
      voiceCloning: json['voice_cloning'] ?? false,
      unlimitedTts: json['unlimited_tts'] ?? false,
      customVoices: json['custom_voices'] ?? false,
      highQualityAudio: json['high_quality_audio'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voice_cloning': voiceCloning,
      'unlimited_tts': unlimitedTts,
      'custom_voices': customVoices,
      'high_quality_audio': highQualityAudio,
    };
  }
}

// User Quota Response Model
class UserQuotaResponse {
  final bool success;
  final String plan;
  final int usageToday;
  final int maxRequests;
  final int remainingRequests;
  final bool hasQuota;
  final UserSubscriptionFeatures features;
  final int voiceClonesUsed;
  final int voiceClonesLimit;

  UserQuotaResponse({
    required this.success,
    required this.plan,
    required this.usageToday,
    required this.maxRequests,
    required this.remainingRequests,
    required this.hasQuota,
    required this.features,
    required this.voiceClonesUsed,
    required this.voiceClonesLimit,
  });

  factory UserQuotaResponse.fromJson(Map<String, dynamic> json) {
    return UserQuotaResponse(
      success: json['success'] ?? false,
      plan: json['plan'] ?? 'free',
      usageToday: json['usage_today'] ?? 0,
      maxRequests: json['max_requests'] ?? 0,
      remainingRequests: json['remaining_requests'] ?? 0,
      hasQuota: json['has_quota'] ?? false,
      features: UserSubscriptionFeatures.fromJson(json['features'] ?? {}),
      voiceClonesUsed: json['voice_clones_used'] ?? 0,
      voiceClonesLimit: json['voice_clones_limit'] ?? (json['features']?['custom_voices'] == true ? 5 : 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'plan': plan,
      'usage_today': usageToday,
      'max_requests': maxRequests,
      'remaining_requests': remainingRequests,
      'has_quota': hasQuota,
      'features': features.toJson(),
      'voice_clones_used': voiceClonesUsed,
      'voice_clones_limit': voiceClonesLimit,
    };
  }

  // Computed properties for compatibility
  int get monthlyCharacterLimit => maxRequests;
  int get charactersUsedThisMonth => usageToday;
  int get charactersRemaining => remainingRequests;
  int get voiceClonesRemaining => voiceClonesLimit - voiceClonesUsed;

  double get characterUsagePercentage {
    if (maxRequests == 0) return 0.0;
    return (usageToday / maxRequests) * 100;
  }

  double get voiceCloneUsagePercentage {
    if (voiceClonesLimit == 0) return 0.0;
    return (voiceClonesUsed / voiceClonesLimit) * 100;
  }
}
