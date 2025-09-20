import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  UserProfile? _userProfile;
  UserStatistics? _userStatistics;
  String? _sessionToken;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  UserStatistics? get userStatistics => _userStatistics;
  String? get sessionToken => _sessionToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && _sessionToken != null;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  // Register new user
  Future<bool> registerUser(UserRegistrationRequest request) async {
    try {
      _setLoading(true);
      clearError();
      
      final user = await UserService.registerUser(request);
      _currentUser = user;
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get user by username
  Future<bool> getUserByUsername(String userName) async {
    try {
      _setLoading(true);
      clearError();
      
      final user = await UserService.getUserByUsername(userName);
      _currentUser = user;
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get full user profile
  Future<bool> getUserProfile(String userName) async {
    try {
      _setLoading(true);
      clearError();
      
      final profile = await UserService.getUserProfile(userName);
      _userProfile = profile;
      _currentUser = profile.user;
      _userStatistics = profile.statistics;
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get user statistics
  Future<bool> getUserStatistics(String userName) async {
    try {
      _setLoading(true);
      clearError();
      
      final statistics = await UserService.getUserStatistics(userName);
      _userStatistics = statistics;
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Record user login
  Future<bool> recordUserLogin(String userName) async {
    try {
      clearError();
      
      final loginResponse = await UserService.recordUserLogin(userName);
      
      // Update statistics if we have them and login response is available
      if (_userStatistics != null && loginResponse != null) {
        _userStatistics = UserStatistics(
          totalConversations: _userStatistics!.totalConversations,
          totalMessages: _userStatistics!.totalMessages,
          streakDays: loginResponse.streakDays,
          averageMessagesPerConversation: _userStatistics!.averageMessagesPerConversation,
          lastLogin: loginResponse.lastLogin,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Authenticate user with password
  Future<bool> authenticateUser(String email, String password) async {
    try {
      _setLoading(true);
      clearError();
      
      final loginResponse = await UserService.authenticateUser(email, password);
      _currentUser = loginResponse.user;
      _sessionToken = loginResponse.sessionToken;
      print('🔐 UserProvider: Session token stored: ${_sessionToken != null ? _sessionToken!.substring(0, 20) + "..." : "NULL"}');
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(String userName, UserProfileUpdateRequest request) async {
    try {
      _setLoading(true);
      clearError();
      
      final updatedUser = await UserService.updateUserProfile(userName, request);
      _currentUser = updatedUser;
      
      // Update user in profile if it exists
      if (_userProfile != null) {
        _userProfile = UserProfile(
          user: updatedUser,
          statistics: _userProfile!.statistics,
        );
      }
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update user level
  Future<bool> updateUserLevel(String userName, String newLevel) async {
    try {
      _setLoading(true);
      clearError();
      
      final request = UserLevelUpdateRequest(userLevel: newLevel);
      await UserService.updateUserLevel(userName, request);
      
      // Update local user data
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(userLevel: newLevel);
      }
      
      if (_userProfile != null) {
        _userProfile = UserProfile(
          user: _userProfile!.user.copyWith(userLevel: newLevel),
          statistics: _userProfile!.statistics,
        );
      }
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Check API health
  Future<bool> checkHealth() async {
    try {
      clearError();
      
      await UserService.checkHealth();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Logout user
  void logout() {
    _currentUser = null;
    _userProfile = null;
    _userStatistics = null;
    _sessionToken = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Set current user (for testing or manual setting)
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Set user profile (for testing or manual setting)
  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    _currentUser = profile.user;
    _userStatistics = profile.statistics;
    notifyListeners();
  }

  // Get user level display name
  String getUserLevelDisplayName() {
    if (_currentUser == null) return '';
    return UserService.getUserLevelDisplayName(_currentUser!.userLevel);
  }

  // Check if user level is valid
  bool isValidUserLevel(String level) {
    return UserService.isValidUserLevel(level);
  }

  // Get all valid user levels
  List<String> getValidUserLevels() {
    return UserService.getValidUserLevels();
  }

}
