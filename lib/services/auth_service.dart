import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'user_service.dart';

class AuthService {
  static const String _sessionTokenKey = 'session_token';
  static const String _userDataKey = 'user_data';
  
  static String get baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';

  // Login with email and password
  static Future<LoginResponse> login(String email, String password) async {
    try {
      // Use UserService for authentication (which now includes proper password validation)
      final loginResponse = await UserService.authenticateUser(email, password);
      
      // Store session token in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionTokenKey, loginResponse.sessionToken);
      
      // Store user data
      await prefs.setString(_userDataKey, jsonEncode(loginResponse.user.toJson()));
      
      return loginResponse;
    } catch (e) {
      print('EXCEPTION in login: $e');
      if (e.toString().contains('Invalid username or password') || 
          e.toString().contains('User not found')) {
        throw Exception('Invalid username or password');
      }
      throw Exception('Network error: $e');
    }
  }

  // Get stored session token
  static Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionTokenKey);
  }

  // Get stored user data
  static Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    
    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        return User.fromJson(userData);
      } catch (e) {
        print('Error parsing stored user data: $e');
        return null;
      }
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final sessionToken = await getSessionToken();
    if (sessionToken == null) return false;
    
    // Verify session token with server
    return await verifySessionToken(sessionToken);
  }

  // Verify session token with server
  static Future<bool> verifySessionToken(String sessionToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': sessionToken,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Session expired, clear local data
        await clearSession();
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print('EXCEPTION in verifySessionToken: $e');
      return false;
    }
  }

  // Logout user
  static Future<void> logout() async {
    final sessionToken = await getSessionToken();
    
    if (sessionToken != null) {
      try {
        // Call logout endpoint
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': sessionToken,
          },
        );
      } catch (e) {
        print('Logout API call failed: $e');
        // Continue with local cleanup even if API call fails
      }
    }
    
    // Clear local session data
    await clearSession();
  }

  // Clear session data from local storage
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_userDataKey);
  }

  // Get authentication headers for API calls
  static Future<Map<String, String>> getAuthHeaders() async {
    final sessionToken = await getSessionToken();
    
    if (sessionToken == null) {
      throw Exception('No session token found - user not authenticated');
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': sessionToken,
    };
  }

  // Handle session expiration
  static Future<void> handleSessionExpired() async {
    print('Session expired, clearing local data');
    await clearSession();
    // Note: Navigation to login screen should be handled by the UI layer
  }

  // Check session and handle expiration automatically
  static Future<bool> checkSessionAndHandleExpiration() async {
    final sessionToken = await getSessionToken();
    if (sessionToken == null) return false;
    
    final isValid = await verifySessionToken(sessionToken);
    if (!isValid) {
      await handleSessionExpired();
    }
    return isValid;
  }
}
