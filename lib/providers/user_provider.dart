import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  UserProfile? _userProfile;
  UserStatistics? _userStatistics;
  String? _sessionToken; // This is now the access_token
  String? _refreshToken;
  DateTime? _tokenExpiresAt;
  bool _isLoading = false;
  String? _error;
  
  // Token persistence keys
  static const String _tokenKey = 'user_session_token';
  static const String _refreshTokenKey = 'user_refresh_token';
  static const String _tokenExpiresKey = 'token_expires_at';
  static const String _userEmailKey = 'user_email';
  static const String _userDataKey = 'user_data';
  
  // Base URL for API calls
  static String get _baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';

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
      _sessionToken = loginResponse.accessToken;  // Use accessToken instead of sessionToken
      _refreshToken = loginResponse.refreshToken;  // Store refresh token
      _tokenExpiresAt = loginResponse.expiresAt ?? DateTime.now().add(Duration(seconds: loginResponse.expiresIn));
      
      // Save authentication data to persistent storage (including refresh token)
      await _saveAuthData(_sessionToken!, _refreshToken!, email, _currentUser!, _tokenExpiresAt!);
      
      print('🔐 UserProvider: Access token stored: ${_sessionToken != null ? _sessionToken!.substring(0, 20) + "..." : "NULL"}');
      print('🔐 UserProvider: Refresh token stored: ${_refreshToken != null ? _refreshToken!.substring(0, 20) + "..." : "NULL"}');
      print('🔐 UserProvider: Token expires at: $_tokenExpiresAt');
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
  Future<void> logout() async {
    // Clear stored authentication data
    await _clearAuthData();
    
    _currentUser = null;
    _userProfile = null;
    _userStatistics = null;
    _sessionToken = null;
    _refreshToken = null;
    _tokenExpiresAt = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
    
    print('🔐 User logged out and auth data cleared');
  }

  // Handle token expiration - called when 401 errors are detected
  Future<void> handleTokenExpiration() async {
    print('🔐 Token expired, logging out user automatically');
    await logout();
  }

  // Refresh access token using refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) {
      print('🔄 No refresh token available, cannot refresh');
      return false;
    }

    try {
      print('🔄 Refreshing access token...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': _refreshToken}),
      ).timeout(const Duration(seconds: 10));

      print('🔄 Refresh response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔄 Refresh response body: $data');
        
        // Update tokens with safe type conversion
        final newAccessToken = data['access_token']?.toString() ?? '';
        final newRefreshToken = data['refresh_token']?.toString() ?? _refreshToken;
        
        // Safe parsing of expires_in (can be int or string)
        int expiresInSeconds = 3600;
        if (data['expires_in'] != null) {
          if (data['expires_in'] is int) {
            expiresInSeconds = data['expires_in'];
          } else if (data['expires_in'] is String) {
            expiresInSeconds = int.tryParse(data['expires_in']) ?? 3600;
          }
        }
        
        // Safe parsing of expires_at (can be string or int timestamp)
        DateTime expiresAt;
        if (data['expires_at'] != null) {
          if (data['expires_at'] is String) {
            try {
              expiresAt = DateTime.parse(data['expires_at']);
            } catch (e) {
              print('🔄 Failed to parse expires_at as string, using expires_in');
              expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
            }
          } else if (data['expires_at'] is int) {
            expiresAt = DateTime.fromMillisecondsSinceEpoch(data['expires_at'] * 1000);
          } else {
            expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
          }
        } else {
          expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
        }
        
        _sessionToken = newAccessToken;
        _refreshToken = newRefreshToken;
        _tokenExpiresAt = expiresAt;
        
        // Save updated tokens to storage
        if (_currentUser != null) {
          final prefs = await SharedPreferences.getInstance();
          final email = prefs.getString(_userEmailKey) ?? '';
          await _saveAuthData(newAccessToken, newRefreshToken!, email, _currentUser!, expiresAt);
        }
        
        print('✅ Token refreshed successfully');
        print('🔄 New access token: ${newAccessToken.substring(0, 20)}...');
        print('🔄 Token expires at: $expiresAt');
        
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        // Refresh token is expired or invalid
        print('🔴 Refresh token expired, logging out');
        await logout();
        return false;
      } else {
        print('🔴 Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('🔴 Error refreshing token: $e');
      return false;
    }
  }

  // Check if token needs refresh (expires in less than 5 minutes)
  bool shouldRefreshToken() {
    if (_tokenExpiresAt == null) return false;
    
    final now = DateTime.now();
    final timeUntilExpiry = _tokenExpiresAt!.difference(now);
    
    // Refresh if token expires in less than 5 minutes
    return timeUntilExpiry.inMinutes < 5;
  }

  // Get valid access token (auto-refresh if needed)
  Future<String?> getValidAccessToken() async {
    print('🔐 UserProvider.getValidAccessToken() called');
    
    if (_sessionToken == null) {
      print('🔐 No session token available');
      return null;
    }

    print('🔐 Current token: ${_sessionToken!.substring(0, 20)}...');
    print('🔐 Token expires at: $_tokenExpiresAt');
    print('🔐 Current time: ${DateTime.now()}');

    // Check if token needs refresh
    if (shouldRefreshToken()) {
      final timeUntilExpiry = _tokenExpiresAt!.difference(DateTime.now());
      print('🔄 Token expiring soon (in ${timeUntilExpiry.inMinutes} minutes), refreshing proactively...');
      final refreshed = await refreshAccessToken();
      
      if (!refreshed) {
        print('🔴 Failed to refresh token');
        return null;
      }
      
      print('✅ Token refreshed, new token: ${_sessionToken!.substring(0, 20)}...');
    } else {
      final timeUntilExpiry = _tokenExpiresAt != null 
        ? _tokenExpiresAt!.difference(DateTime.now()).inMinutes 
        : -1;
      print('✅ Token still valid (expires in $timeUntilExpiry minutes)');
    }

    return _sessionToken;
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

  // Clear cached user data (for fixing UUID issues)
  Future<void> clearCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      print('🔐 Cached user data cleared');
    } catch (e) {
      print('🔐 Failed to clear cached user data: $e');
    }
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

  // ===== TOKEN PERSISTENCE METHODS =====
  
  // Save authentication data to persistent storage
  Future<void> _saveAuthData(String accessToken, String refreshToken, String email, User user, DateTime expiresAt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
      await prefs.setString(_tokenExpiresKey, expiresAt.toIso8601String());
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
      print('🔐 Auth data saved to persistent storage (access + refresh tokens)');
    } catch (e) {
      print('🔐 Failed to save auth data: $e');
    }
  }

  // Load authentication data from persistent storage
  Future<bool> _loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final refreshToken = prefs.getString(_refreshTokenKey);
      final expiresAtString = prefs.getString(_tokenExpiresKey);
      final email = prefs.getString(_userEmailKey);
      final userDataString = prefs.getString(_userDataKey);

      if (token != null && email != null && userDataString != null) {
        print('🔐 Found stored auth data, attempting auto-login...');
        
        // Set tokens and expiration
        _sessionToken = token;
        _refreshToken = refreshToken;
        if (expiresAtString != null) {
          _tokenExpiresAt = DateTime.parse(expiresAtString);
        }
        
        // Parse and set user data
        try {
          final userData = jsonDecode(userDataString);
          _currentUser = User.fromJson(userData);
          print('🔐 Stored user data loaded successfully');
        } catch (e) {
          print('🔐 Failed to parse stored user data: $e');
          return false;
        }
        
        print('🔐 Stored access token found: ${token.substring(0, 20)}...');
        print('🔐 Stored refresh token found: ${refreshToken != null ? refreshToken.substring(0, 20) + "..." : "NULL"}');
        print('🔐 Token expires at: $_tokenExpiresAt');
        
        return true;
      } else {
        print('🔐 No stored auth data found');
        return false;
      }
    } catch (e) {
      print('🔐 Failed to load auth data: $e');
      return false;
    }
  }

  // Clear authentication data from persistent storage
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_tokenExpiresKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userDataKey);
      print('🔐 Auth data cleared from persistent storage');
    } catch (e) {
      print('🔐 Failed to clear auth data: $e');
    }
  }

  // Validate stored token with backend
  Future<bool> _validateStoredToken(String token) async {
    try {
      // Call the token validation endpoint
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) {
          print('🔐 Token validation successful');
          
          // Update user data if provided
          if (data['user'] != null) {
            _currentUser = User.fromJson(data['user']);
            // Update stored user data
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_userDataKey, jsonEncode(data['user']));
          }
          
          return true;
        }
      }
      
      print('🔐 Token validation failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('🔐 Token validation failed: $e');
      return false;
    }
  }

  // Initialize authentication on app startup
  Future<void> initializeAuth() async {
    try {
      _setLoading(true);
      print('🔐 Initializing authentication...');
      
      // Try to load stored auth data
      final hasStoredData = await _loadAuthData();
      
      if (hasStoredData && _sessionToken != null) {
        // Validate the stored token
        final isValid = await _validateStoredToken(_sessionToken!);
        
        if (isValid) {
          print('🔐 Auto-login successful');
          _setLoading(false);
          notifyListeners();
          return;
        } else {
          // Token is invalid, clear stored data
          print('🔐 Stored token invalid, clearing auth data');
          await _clearAuthData();
        }
      }
      
      print('🔐 No valid stored authentication found');
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      print('🔐 Auth initialization failed: $e');
      _setLoading(false);
      notifyListeners();
    }
  }

}
