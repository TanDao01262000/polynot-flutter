import 'package:flutter/foundation.dart';
import '../services/user_subscription_service.dart';
import 'user_provider.dart';

class UserPlanProvider extends ChangeNotifier {
  UserSubscriptionResponse? _subscription;
  UserQuotaResponse? _quota;
  bool _isLoading = false;
  String? _error;
  String? _sessionToken;
  UserProvider? _userProvider; // Reference to UserProvider for token refresh

  // Getters
  UserSubscriptionResponse? get subscription => _subscription;
  UserQuotaResponse? get quota => _quota;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get sessionToken => _sessionToken;

  // Plan status getters
  bool get isPremium => _subscription?.isPremium ?? false;
  bool get isFree => _subscription?.isFree ?? true;
  bool get isActive => _subscription?.isActive ?? false;
  String get planName => _subscription?.plan ?? 'free';

  // Feature access getters
  bool get canUseVoiceCloning => _subscription?.features.voiceCloning ?? false;
  bool get hasUnlimitedTts => _subscription?.features.unlimitedTts ?? false;
  bool get canUseCustomVoices => _subscription?.features.customVoices ?? false;
  bool get hasHighQualityAudio => _subscription?.features.highQualityAudio ?? false;

  // Quota getters
  int get charactersUsed => _quota?.charactersUsedThisMonth ?? 0;
  int get charactersLimit => _quota?.monthlyCharacterLimit ?? 0;
  int get charactersRemaining => _quota?.charactersRemaining ?? 0;
  double get characterUsagePercentage => _quota?.characterUsagePercentage ?? 0.0;

  int get voiceClonesUsed => _quota?.voiceClonesUsed ?? 0;
  int get voiceClonesLimit => _quota?.voiceClonesLimit ?? 0;
  int get voiceClonesRemaining => _quota?.voiceClonesRemaining ?? 0;
  double get voiceCloneUsagePercentage => _quota?.voiceCloneUsagePercentage ?? 0.0;

  DateTime? get quotaResetDate => null; // Not provided in current API
  DateTime? get subscriptionExpiresAt => _subscription?.expiresAt;

  // Set session token and user provider reference
  void setSessionToken(String? token, {UserProvider? userProvider}) {
    _sessionToken = token;
    _userProvider = userProvider;
    if (token != null) {
      print('📋 UserPlanProvider: Set session token: ${token.substring(0, 20)}...');
      print('📋 UserPlanProvider: UserProvider reference: ${userProvider != null ? "SET ✅" : "NULL ❌"}');
    } else {
      print('📋 UserPlanProvider: Cleared session token');
    }
  }

  // Get valid token with auto-refresh
  Future<String?> _getValidToken() async {
    print('📋 UserPlanProvider: _getValidToken called');
    print('📋 UserPlanProvider: _userProvider is ${_userProvider != null ? "SET" : "NULL"}');
    print('📋 UserPlanProvider: _sessionToken is ${_sessionToken != null ? "SET (${_sessionToken!.substring(0, 20)}...)" : "NULL"}');
    
    if (_userProvider != null) {
      print('📋 UserPlanProvider: Using UserProvider.getValidAccessToken() for auto-refresh');
      final token = await _userProvider!.getValidAccessToken();
      print('📋 UserPlanProvider: Got token from UserProvider: ${token != null ? "${token.substring(0, 20)}..." : "NULL"}');
      return token;
    }
    
    print('📋 UserPlanProvider: WARNING - No UserProvider, using _sessionToken (may be expired!)');
    return _sessionToken;
  }

  // Load user subscription information
  Future<void> loadUserSubscription() async {
    if (_sessionToken == null) {
      print('📋 UserPlanProvider: No session token set');
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      print('📋 UserPlanProvider: Loading user subscription...');
      
      // Get valid token (auto-refresh if needed)
      final validToken = await _getValidToken();
      if (validToken == null) {
        throw Exception('Failed to get valid authentication token');
      }
      
      _subscription = await UserSubscriptionService.getUserSubscription(validToken);
      print('📋 UserPlanProvider: Subscription loaded - Plan: ${_subscription?.plan}, Status: ${_subscription?.status}');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('📋 UserPlanProvider: Error loading subscription: $e');
      
      // If it's a 401 error, try refreshing once and retry
      if (e.toString().contains('401') && _userProvider != null) {
        print('🔄 Attempting to refresh token and retry...');
        final refreshed = await _userProvider!.refreshAccessToken();
        
        if (refreshed) {
          // Retry with new token
          try {
            final newToken = _userProvider!.sessionToken;
            if (newToken != null) {
              _subscription = await UserSubscriptionService.getUserSubscription(newToken);
              print('✅ Subscription loaded successfully after token refresh');
              _error = null;
              notifyListeners();
              _setLoading(false);
              return;
            }
          } catch (retryError) {
            print('🔴 Retry failed after token refresh: $retryError');
          }
        }
      }
      
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load user quota information
  Future<void> loadUserQuota() async {
    if (_sessionToken == null) {
      print('📋 UserPlanProvider: No session token set');
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      print('📋 UserPlanProvider: Loading user quota...');
      
      // Get valid token (auto-refresh if needed)
      final validToken = await _getValidToken();
      if (validToken == null) {
        throw Exception('Failed to get valid authentication token');
      }
      
      _quota = await UserSubscriptionService.getUserQuota(validToken);
      print('📋 UserPlanProvider: Quota loaded - Characters: ${_quota?.charactersUsedThisMonth}/${_quota?.monthlyCharacterLimit}');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('📋 UserPlanProvider: Error loading quota: $e');
      
      // If it's a 401 error, try refreshing once and retry
      if (e.toString().contains('401') && _userProvider != null) {
        print('🔄 Attempting to refresh token and retry...');
        final refreshed = await _userProvider!.refreshAccessToken();
        
        if (refreshed) {
          // Retry with new token
          try {
            final newToken = _userProvider!.sessionToken;
            if (newToken != null) {
              _quota = await UserSubscriptionService.getUserQuota(newToken);
              print('✅ Quota loaded successfully after token refresh');
              _error = null;
              notifyListeners();
              _setLoading(false);
              return;
            }
          } catch (retryError) {
            print('🔴 Retry failed after token refresh: $retryError');
          }
        }
      }
      
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load both subscription and quota
  Future<void> loadUserPlan() async {
    if (_sessionToken == null) {
      print('📋 UserPlanProvider: No session token set');
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      print('📋 UserPlanProvider: Loading user plan information...');
      
      // Get valid token (auto-refresh if needed)
      final validToken = await _getValidToken();
      if (validToken == null) {
        throw Exception('Failed to get valid authentication token');
      }
      
      // Load both subscription and quota in parallel with VALID token
      final results = await Future.wait([
        UserSubscriptionService.getUserSubscription(validToken),
        UserSubscriptionService.getUserQuota(validToken),
      ]);

      _subscription = results[0] as UserSubscriptionResponse;
      _quota = results[1] as UserQuotaResponse;

      print('📋 UserPlanProvider: Plan loaded successfully');
      print('📋 UserPlanProvider: Plan: ${_subscription?.plan}, Status: ${_subscription?.status}');
      print('📋 UserPlanProvider: Characters: ${_quota?.charactersUsedThisMonth}/${_quota?.monthlyCharacterLimit}');
      print('📋 UserPlanProvider: Voice clones: ${_quota?.voiceClonesUsed}/${_quota?.voiceClonesLimit}');
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('📋 UserPlanProvider: Error loading plan: $e');
      
      // If it's a 401 error, try refreshing once and retry
      if (e.toString().contains('401') && _userProvider != null) {
        print('🔄 Attempting to refresh token and retry...');
        final refreshed = await _userProvider!.refreshAccessToken();
        
        if (refreshed) {
          // Retry with new token
          try {
            final newToken = await _getValidToken();
            if (newToken != null) {
              final results = await Future.wait([
                UserSubscriptionService.getUserSubscription(newToken),
                UserSubscriptionService.getUserQuota(newToken),
              ]);
              
              _subscription = results[0] as UserSubscriptionResponse;
              _quota = results[1] as UserQuotaResponse;
              
              print('✅ Plan loaded successfully after token refresh');
              _error = null;
              notifyListeners();
              _setLoading(false);
              return;
            }
          } catch (retryError) {
            print('🔴 Retry failed after token refresh: $retryError');
          }
        }
      }
      
      print('🔴 UserPlanProvider: Authentication failed (401) - Token expired or invalid');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user plan data
  Future<void> refreshUserPlan() async {
    print('📋 UserPlanProvider: Refreshing user plan...');
    await loadUserPlan();
  }

  // Check if user can perform a specific action
  bool canPerformAction(String action) {
    switch (action) {
      case 'voice_cloning':
        return canUseVoiceCloning;
      case 'unlimited_tts':
        return hasUnlimitedTts;
      case 'custom_voices':
        return canUseCustomVoices;
      case 'tts_generation':
        return charactersRemaining > 0 || hasUnlimitedTts;
      default:
        return false;
    }
  }

  // Get plan display information
  Map<String, dynamic> getPlanDisplayInfo() {
    return {
      'plan_name': planName.toUpperCase(),
      'is_premium': isPremium,
      'is_active': isActive,
      'expires_at': subscriptionExpiresAt,
      'features': {
        'voice_cloning': canUseVoiceCloning,
        'unlimited_tts': hasUnlimitedTts,
        'custom_voices': canUseCustomVoices,
        'high_quality_audio': hasHighQualityAudio,
      },
      'quota': {
        'characters_used': charactersUsed,
        'characters_limit': charactersLimit,
        'characters_remaining': charactersRemaining,
        'character_usage_percentage': characterUsagePercentage,
        'voice_clones_used': voiceClonesUsed,
        'voice_clones_limit': voiceClonesLimit,
        'voice_clones_remaining': voiceClonesRemaining,
        'voice_clone_usage_percentage': voiceCloneUsagePercentage,
        'reset_date': quotaResetDate,
      },
    };
  }

  // Clear all data
  void clear() {
    _subscription = null;
    _quota = null;
    _error = null;
    _sessionToken = null;
    _setLoading(false);
    print('📋 UserPlanProvider: Cleared all data');
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
