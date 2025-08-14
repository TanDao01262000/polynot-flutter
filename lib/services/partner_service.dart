import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/partner.dart';

class PartnerService {
  static String get baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';

  // Fetch all partners (both premade and custom)
  static Future<List<Partner>> fetchAllPartners() async {
    try {
      final uri = Uri.parse('$baseUrl/partners/');
      
      print('Fetching partners from: $uri');
      
      final response = await http.get(uri);

      print('Partners Response Status: ${response.statusCode}');
      print('Partners Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> partnersJson = jsonDecode(response.body);
        return partnersJson.map((json) => Partner.fromJson(json)).toList();
      } else {
        print('ERROR: Failed to fetch partners - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to fetch partners: ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION in fetchAllPartners: $e');
      throw Exception('Network error: $e');
    }
  }

  // Create a new user
  static Future<Map<String, dynamic>> createUser(String userName, String userLevel, String targetLanguage) async {
    try {
      final uri = Uri.parse('$baseUrl/users/');
      
      print('Creating user at: $uri');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': userName,
          'user_level': userLevel,
          'target_language': targetLanguage,
        }),
      );

      print('Create User Response Status: ${response.statusCode}');
      print('Create User Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('ERROR: Failed to create user - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION in createUser: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get user information
  static Future<Map<String, dynamic>> getUser(String userName) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userName');
      
      print('Getting user from: $uri');
      
      final response = await http.get(uri);

      print('Get User Response Status: ${response.statusCode}');
      print('Get User Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('ERROR: Failed to get user - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION in getUser: $e');
      throw Exception('Network error: $e');
    }
  }

  // Check API health
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/');
      
      print('Checking API health at: $uri');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Health check timeout after 5 seconds');
        },
      );

      print('Health Check Response Status: ${response.statusCode}');
      print('Health Check Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (jsonError) {
          print('Warning: Health check returned non-JSON response: $jsonError');
          // Return a simple status if JSON parsing fails
          return {'status': 'ok', 'message': 'API is running'};
        }
      } else {
        print('ERROR: Health check failed - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION in checkHealth: $e');
      throw Exception('Network error: $e');
    }
  }
} 