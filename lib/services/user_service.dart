import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import 'password_service.dart';

class UserService {
  static String get baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';

  // 1. User Registration
  static Future<User> registerUser(UserRegistrationRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/users/');
      
      print('Registering user at: $uri');
      print('Request body: ${jsonEncode(request.toJson())}');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print('Register User Response Status: ${response.statusCode}');
      print('Register User Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final user = User.fromJson(jsonDecode(response.body));
        
        // Store the password securely for future authentication
        await PasswordService.storePassword(request.userName, request.password);
        
        return user;
      } else {
        print('ERROR: Failed to register user - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to register user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION in registerUser: $e');
      throw Exception('Network error: $e');
    }
  }

  // 2.1 Get User by Username
  static Future<User> getUserByUsername(String userName) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userName');
      
      print('Getting user from: $uri');
      
      final response = await http.get(uri);

      print('Get User Response Status: ${response.statusCode}');
      print('Get User Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        print('ERROR: Failed to get user - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to get user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION in getUserByUsername: $e');
      throw Exception('Network error: $e');
    }
  }

  // 2.2 Get User Profile (Full)
  static Future<UserProfile> getUserProfile(String userName) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userName/profile');
      
      print('Getting user profile from: $uri');
      
      final response = await http.get(uri);

      print('Get User Profile Response Status: ${response.statusCode}');
      print('Get User Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('User profile not found');
      } else {
        print('ERROR: Failed to get user profile - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to get user profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION in getUserProfile: $e');
      throw Exception('Network error: $e');
    }
  }

  // 2.3 Get User Statistics
  static Future<UserStatistics> getUserStatistics(String userName) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userName/statistics');
      
      print('Getting user statistics from: $uri');
      
      final response = await http.get(uri);

      print('Get User Statistics Response Status: ${response.statusCode}');
      print('Get User Statistics Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return UserStatistics.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('User statistics not found');
      } else {
        print('ERROR: Failed to get user statistics - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to get user statistics: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION in getUserStatistics: $e');
      throw Exception('Network error: $e');
    }
  }

  // 2.4 Record User Login
  static Future<LoginResponse> recordUserLogin(String userName) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userName/login');
      
      print('Recording user login at: $uri');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('Record Login Response Status: ${response.statusCode}');
      print('Record Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (responseBody.isEmpty) {
          print('WARNING: Empty response body from login endpoint');
          throw Exception('Empty response from login endpoint');
        }
        
        final jsonData = jsonDecode(responseBody);
        if (jsonData == null) {
          print('WARNING: Null JSON data from login endpoint');
          throw Exception('Null response from login endpoint');
        }
        
        return LoginResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        print('ERROR: Failed to record login - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to record login: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION in recordUserLogin: $e');
      throw Exception('Network error: $e');
    }
  }

  // 2.5 Authenticate User with Password
  static Future<LoginResponse> authenticateUser(String userName, String password) async {
    try {
      // First, get the user's profile to verify they exist
      final user = await getUserByUsername(userName);
      
      // CRITICAL SECURITY FIX: Implement proper password validation
      // Verify the password against the stored hash
      final isPasswordValid = await PasswordService.verifyPassword(userName, password);
      
      if (!isPasswordValid) {
        throw Exception('Invalid username or password');
      }
      
      // Generate a session token (in a real app, this would come from the server)
      final sessionToken = 'session_${userName}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create a login response
      final loginResponse = LoginResponse(
        user: user,
        sessionToken: sessionToken,
        streakDays: user.streakDays,
        lastLogin: DateTime.now(),
      );
      
      print('User authentication successful for: $userName');
      return loginResponse;
    } catch (e) {
      print('EXCEPTION in authenticateUser: $e');
      if (e.toString().contains('User not found')) {
        throw Exception('Invalid username or password');
      }
      throw Exception('Invalid username or password');
    }
  }

  // 3.1 Update User Profile
  static Future<User> updateUserProfile(String userName, UserProfileUpdateRequest request) async {
    try {
      // Use the correct profile endpoint that was working before
      final uri = Uri.parse('$baseUrl/users/$userName/profile');
      
      print('Updating user profile at: $uri');
      print('Request body: ${jsonEncode(request.toJson())}');
      print('Request data keys: ${request.toJson().keys.toList()}');
      print('Request data values: ${request.toJson().values.toList()}');
      
      // Try PATCH method with different endpoint structure
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print('Update Profile Response Status: ${response.statusCode}');
      print('Update Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        print('ERROR: Failed to update profile - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to update profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION in updateUserProfile: $e');
      throw Exception('Network error: $e');
    }
  }

  // 3.2 Update User Level
  static Future<Map<String, dynamic>> updateUserLevel(String userName, UserLevelUpdateRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userName/level');
      
      print('Updating user level at: $uri');
      print('Request body: ${jsonEncode(request.toJson())}');
      
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print('Update Level Response Status: ${response.statusCode}');
      print('Update Level Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        print('ERROR: Failed to update level - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to update level: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION in updateUserLevel: $e');
      throw Exception('Network error: $e');
    }
  }

  // 6.1 Health Check
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      
      print('Checking API health at: $uri');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Health check timeout');
        },
      );

      print('Health Check Response Status: ${response.statusCode}');
      print('Health Check Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('ERROR: Health check failed - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION in checkHealth: $e');
      throw Exception('Health check error: $e');
    }
  }

  // 6.2 Database Migration (Admin only)
  static Future<Map<String, dynamic>> runMigration() async {
    try {
      final uri = Uri.parse('$baseUrl/migrate');
      
      print('Running database migration at: $uri');
      
      final response = await http.post(uri);

      print('Migration Response Status: ${response.statusCode}');
      print('Migration Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('ERROR: Migration failed - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Migration failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION in runMigration: $e');
      throw Exception('Migration error: $e');
    }
  }

  // Helper method to validate user level
  static bool isValidUserLevel(String level) {
    const validLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    return validLevels.contains(level.toUpperCase());
  }

  // Helper method to get user level display name
  static String getUserLevelDisplayName(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return 'Beginner';
      case 'A2':
        return 'Elementary';
      case 'B1':
        return 'Intermediate';
      case 'B2':
        return 'Upper Intermediate';
      case 'C1':
        return 'Advanced';
      case 'C2':
        return 'Proficient';
      default:
        return level;
    }
  }

  // Helper method to get all valid user levels
  static List<String> getValidUserLevels() {
    return ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  }

  // 7.1 Logout User
  static Future<void> logoutUser(String sessionToken) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/logout');
      
      print('Logging out user at: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': sessionToken,
        },
      );

      print('Logout Response Status: ${response.statusCode}');
      print('Logout Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('User logged out successfully');
      } else {
        print('WARNING: Logout API call failed - ${response.statusCode}');
        print('Error Body: ${response.body}');
        // Don't throw exception for logout failures - still clear local session
      }
    } catch (e) {
      print('EXCEPTION in logoutUser: $e');
      // Don't throw exception for logout failures - still clear local session
    }
  }

  // 7.2 Verify Session Token
  static Future<bool> verifySessionToken(String sessionToken) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/verify');
      
      print('Verifying session token at: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': sessionToken,
        },
      );

      print('Session Verification Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        return false; // Session expired or invalid
      } else {
        print('ERROR: Session verification failed - ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('EXCEPTION in verifySessionToken: $e');
      return false;
    }
  }
}
