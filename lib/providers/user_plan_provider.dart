import 'package:flutter/foundation.dart';
import '../services/user_subscription_service.dart';

class UserPlanProvider extends ChangeNotifier {
  UserSubscriptionResponse? _subscription;
  UserQuotaResponse? _quota;
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  // Getters
  UserSubscriptionResponse? get subscription => _subscription;
  UserQuotaResponse? get quota => _quota;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _currentUserId;

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

  // Set current user ID
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    print('📋 UserPlanProvider: Set current user ID: ${userId.substring(0, 20)}...');
  }

  // Load user subscription information
  Future<void> loadUserSubscription() async {
    if (_currentUserId == null) {
      print('📋 UserPlanProvider: No current user ID set');
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      print('📋 UserPlanProvider: Loading user subscription...');
      _subscription = await UserSubscriptionService.getUserSubscription(_currentUserId!);
      print('📋 UserPlanProvider: Subscription loaded - Plan: ${_subscription?.plan}, Status: ${_subscription?.status}');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('📋 UserPlanProvider: Error loading subscription: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load user quota information
  Future<void> loadUserQuota() async {
    if (_currentUserId == null) {
      print('📋 UserPlanProvider: No current user ID set');
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      print('📋 UserPlanProvider: Loading user quota...');
      _quota = await UserSubscriptionService.getUserQuota(_currentUserId!);
      print('📋 UserPlanProvider: Quota loaded - Characters: ${_quota?.charactersUsedThisMonth}/${_quota?.monthlyCharacterLimit}');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('📋 UserPlanProvider: Error loading quota: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load both subscription and quota
  Future<void> loadUserPlan() async {
    if (_currentUserId == null) {
      print('📋 UserPlanProvider: No current user ID set');
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      print('📋 UserPlanProvider: Loading user plan information...');
      
      // Load both subscription and quota in parallel
      final results = await Future.wait([
        UserSubscriptionService.getUserSubscription(_currentUserId!),
        UserSubscriptionService.getUserQuota(_currentUserId!),
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
    _currentUserId = null;
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
