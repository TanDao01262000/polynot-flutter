import 'package:flutter/foundation.dart';
import '../models/flashcard_models.dart';
import '../services/flashcard_service.dart';

class FlashcardProvider extends ChangeNotifier {
  // Study configuration
  List<StudyMode> _studyModes = [];
  List<SessionType> _sessionTypes = [];
  List<DifficultyRating> _difficultyRatings = [];

  // Current session state
  FlashcardSession? _currentSession;
  FlashcardCard? _currentCard;
  SessionStats? _sessionStats;
  bool _isSessionActive = false;
  bool _isLoadingSession = false;
  bool _isLoadingCard = false;
  bool _isSubmittingAnswer = false;

  // Session history
  List<FlashcardSession> _sessions = [];
  bool _isLoadingSessions = false;

  // Statistics and analytics
  FlashcardStats? _stats;
  FlashcardAnalytics? _analytics;
  bool _isLoadingStats = false;
  bool _isLoadingAnalytics = false;

  // Error handling
  String? _error;
  String? _sessionError;

  // User ID
  String? _currentUserId;

  // Getters
  List<StudyMode> get studyModes => _studyModes;
  List<SessionType> get sessionTypes => _sessionTypes;
  List<DifficultyRating> get difficultyRatings => _difficultyRatings;
  
  FlashcardSession? get currentSession => _currentSession;
  FlashcardCard? get currentCard => _currentCard;
  SessionStats? get sessionStats => _sessionStats;
  bool get isSessionActive => _isSessionActive;
  bool get isLoadingSession => _isLoadingSession;
  bool get isLoadingCard => _isLoadingCard;
  bool get isSubmittingAnswer => _isSubmittingAnswer;
  
  List<FlashcardSession> get sessions => _sessions;
  bool get isLoadingSessions => _isLoadingSessions;
  
  FlashcardStats? get stats => _stats;
  FlashcardAnalytics? get analytics => _analytics;
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  
  String? get error => _error;
  String? get sessionError => _sessionError;
  String? get currentUserId => _currentUserId;

  // Set current user ID for authenticated requests
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // Initialize with user provider
  void initializeWithUser(String userId) {
    _currentUserId = userId;
    initialize();
  }

  // Clear current user ID
  void clearCurrentUserId() {
    _currentUserId = null;
    _clearSessionData();
    notifyListeners();
  }

  // Initialize flashcard system
  Future<void> initialize() async {
    if (_currentUserId == null) return;

    _isLoadingSession = true;
    _error = null;
    notifyListeners();

    try {
      // Load study modes, session types, and difficulty ratings in parallel
      final results = await Future.wait([
        FlashcardService.getStudyModes(),
        FlashcardService.getSessionTypes(),
        FlashcardService.getDifficultyRatings(),
      ]);

      _studyModes = results[0] as List<StudyMode>;
      _sessionTypes = results[1] as List<SessionType>;
      _difficultyRatings = results[2] as List<DifficultyRating>;

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingSession = false;
      notifyListeners();
    }
  }

  // Create a new flashcard session
  Future<CreateSessionResponse?> createSession(CreateSessionRequest request) async {
    if (_currentUserId == null) {
      _error = 'User must be logged in to create a session';
      notifyListeners();
      return null;
    }

    _isLoadingSession = true;
    _sessionError = null;
    notifyListeners();

    try {
      final response = await FlashcardService.createSession(request, _currentUserId!);
      
      if (response != null && response.success) {
        print('DEBUG: Session created successfully with ID: ${response.sessionId}');
        print('DEBUG: Current card from response: ${response.currentCard?.word}');
        
        _currentSession = FlashcardSession(
          id: response.sessionId,
          sessionName: response.sessionName,
          sessionType: response.sessionType,
          studyMode: response.studyMode,
          topicName: request.topicName,
          categoryName: request.categoryName,
          level: request.level,
          maxCards: request.maxCards,
          timeLimitMinutes: request.timeLimitMinutes,
          includeReviewed: request.includeReviewed,
          includeFavorites: request.includeFavorites,
          difficultyFilter: request.difficultyFilter,
          smartSelection: request.smartSelection,
          totalCards: response.totalCards,
          createdAt: DateTime.now(),
          isActive: true,
        );
        
        _isSessionActive = true;
        _sessionError = null;
        
        // Use the current card from the session creation response
        if (response.currentCard != null) {
          _currentCard = response.currentCard;
          print('DEBUG: Using current card from session creation: ${_currentCard?.word}');
        } else {
          print('DEBUG: No current card in response, loading first card');
          // Fallback to loading the first card
          await _loadCurrentCard();
        }
      } else {
        print('DEBUG: Session creation failed - response: $response');
        _sessionError = 'Failed to create session - please try again';
      }
      
      return response;
    } catch (e) {
      // Enhanced error handling based on backend guide
      if (e.toString().contains('401')) {
        _sessionError = 'Authentication failed - please login again';
      } else if (e.toString().contains('422')) {
        _sessionError = 'Invalid session parameters - please check your settings';
      } else if (e.toString().contains('500')) {
        _sessionError = 'Server error - please try again later';
      } else {
        _sessionError = 'Network error - please check your connection and try again';
      }
      return null;
    } finally {
      _isLoadingSession = false;
      notifyListeners();
    }
  }

  // Load current card in session
  Future<void> _loadCurrentCard() async {
    if (_currentSession == null || _currentUserId == null) return;

    _isLoadingCard = true;
    _sessionError = null;
    notifyListeners();

    try {
      final card = await FlashcardService.getCurrentCard(_currentSession!.id, _currentUserId!);
      _currentCard = card;
      _sessionError = null;
    } catch (e) {
      _sessionError = e.toString();
    } finally {
      _isLoadingCard = false;
      notifyListeners();
    }
  }

  // Submit answer for current card
  Future<FlashcardAnswerResult?> submitAnswer(FlashcardAnswer answer) async {
    if (_currentSession == null || _currentUserId == null) {
      _sessionError = 'No active session';
      notifyListeners();
      return null;
    }

    _isSubmittingAnswer = true;
    _sessionError = null;
    notifyListeners();

    try {
      final result = await FlashcardService.submitAnswer(
        _currentSession!.id,
        answer,
        _currentUserId!,
      );

      if (result != null && result.success) {
        _sessionStats = result.sessionStats;
        
        if (result.sessionComplete) {
          // Session completed
          _isSessionActive = false;
          _currentCard = null;
          // Add to sessions history
          _sessions.insert(0, _currentSession!.copyWith(isActive: false));
        } else if (result.nextCardAvailable) {
          // Load next card
          await _loadCurrentCard();
        }
        
        _sessionError = null;
      } else {
        _sessionError = 'Failed to submit answer - please try again';
      }

      return result;
    } catch (e) {
      // Enhanced error handling based on backend guide
      if (e.toString().contains('401')) {
        _sessionError = 'Authentication failed - please login again';
      } else if (e.toString().contains('404')) {
        _sessionError = 'Session expired or not found - please start a new session';
      } else if (e.toString().contains('422')) {
        _sessionError = 'Invalid answer format - please check your input';
      } else if (e.toString().contains('500')) {
        _sessionError = 'Server error - please try again later';
      } else {
        _sessionError = 'Network error - please check your connection and try again';
      }
      return null;
    } finally {
      _isSubmittingAnswer = false;
      notifyListeners();
    }
  }

  // End current session
  Future<void> endSession() async {
    if (_currentSession == null) return;

    _isSessionActive = false;
    _currentCard = null;
    _sessionStats = null;
    
    // Add to sessions history
    _sessions.insert(0, _currentSession!.copyWith(isActive: false));
    
    notifyListeners();
  }

  // Delete a session
  Future<bool> deleteSession(String sessionId) async {
    if (_currentUserId == null) return false;

    try {
      final success = await FlashcardService.deleteSession(sessionId, _currentUserId!);
      if (success) {
        _sessions.removeWhere((session) => session.id == sessionId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load user's sessions
  Future<void> loadSessions({int limit = 50}) async {
    if (_currentUserId == null) return;

    _isLoadingSessions = true;
    _error = null;
    notifyListeners();

    try {
      final sessions = await FlashcardService.getSessions(_currentUserId!, limit: limit);
      _sessions = sessions;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  // Load user's statistics
  Future<void> loadStats() async {
    if (_currentUserId == null) return;

    _isLoadingStats = true;
    _error = null;
    notifyListeners();

    try {
      final stats = await FlashcardService.getStats(_currentUserId!);
      _stats = stats;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // Load user's analytics
  Future<void> loadAnalytics({int days = 30}) async {
    if (_currentUserId == null) return;

    _isLoadingAnalytics = true;
    _error = null;
    notifyListeners();

    try {
      final analytics = await FlashcardService.getAnalytics(_currentUserId!, days: days);
      _analytics = analytics;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  // Clear session data
  void _clearSessionData() {
    _currentSession = null;
    _currentCard = null;
    _sessionStats = null;
    _isSessionActive = false;
    _isLoadingSession = false;
    _isLoadingCard = false;
    _isSubmittingAnswer = false;
    _sessionError = null;
  }

  // Clear all data
  void clearAll() {
    _clearSessionData();
    _sessions.clear();
    _stats = null;
    _analytics = null;
    _error = null;
    notifyListeners();
  }

  // Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSessionError() {
    _sessionError = null;
    notifyListeners();
  }

  // Helper methods for UI
  bool get hasActiveSession => _isSessionActive && _currentSession != null;
  bool get canSubmitAnswer => _currentCard != null && !_isSubmittingAnswer;
  bool get isSessionComplete => _sessionStats != null && _sessionStats!.cardsRemaining == 0;
  
  double get sessionProgress {
    if (_currentSession == null || _sessionStats == null) return 0.0;
    final total = _currentSession!.totalCards;
    final completed = _sessionStats!.totalAnswered;
    return total > 0 ? completed / total : 0.0;
  }

  // Get study mode by value
  StudyMode? getStudyModeByValue(String value) {
    try {
      return _studyModes.firstWhere((mode) => mode.value == value);
    } catch (e) {
      return null;
    }
  }

  // Get session type by value
  SessionType? getSessionTypeByValue(String value) {
    try {
      return _sessionTypes.firstWhere((type) => type.value == value);
    } catch (e) {
      return null;
    }
  }

  // Get difficulty rating by value
  DifficultyRating? getDifficultyRatingByValue(String value) {
    try {
      return _difficultyRatings.firstWhere((rating) => rating.value == value);
    } catch (e) {
      return null;
    }
  }

  // Refresh current card (useful for retry scenarios)
  Future<void> refreshCurrentCard() async {
    await _loadCurrentCard();
  }

  // Check if service is healthy
  Future<bool> checkServiceHealth() async {
    try {
      return await FlashcardService.checkHealth();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
