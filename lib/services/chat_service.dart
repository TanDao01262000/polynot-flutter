import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';

class ChatService {
  // Get API configuration from environment variables
  static String get baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';
  
  static Future<Message> sendMessage(String userInput, {
    required String partnerId,
    required String userName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_name': userName,
          'partner_id': partnerId,
          'user_input': userInput,
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed Response Data: $data');
        
        final aiResponse = data['response'] ?? 'Sorry, I didn\'t understand that.';
        print('AI Response: $aiResponse');
        
        return Message(
          text: aiResponse,
          isUser: false,
        );
      } else {
        print('ERROR: HTTP ${response.statusCode}');
        print('Error Response Body: ${response.body}');
        print('Error Response Headers: ${response.headers}');
        
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION: $e');
      print('Exception Type: ${e.runtimeType}');
      print('Stack Trace: ${StackTrace.current}');
      
      throw Exception('Network error: $e');
    }
  }

  // Send an initial greeting to start a conversation
  static Future<Map<String, dynamic>> sendInitialGreeting({
    required String partnerId,
    required String userName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/greet'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_name': userName,
          'partner_id': partnerId,
        }),
      );

      print('Initial Greeting Response Status Code: ${response.statusCode}');
      print('Initial Greeting Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed Initial Greeting Response Data: $data');
        
        final aiResponse = data['greeting_message'] ?? 'Hi, how can I help you?';
        final threadId = data['thread_id'] ?? '';
        print('AI Initial Greeting: $aiResponse');
        print('Thread ID: $threadId');
        
        return {
          'greeting_message': aiResponse,
          'thread_id': threadId,
        };
      } else {
        print('ERROR: HTTP ${response.statusCode} for initial greeting');
        print('Error Response Body: ${response.body}');
        
        // Return a default greeting if the backend fails
        return {
          'greeting_message': 'Hi, how can I help you?',
          'thread_id': '',
        };
      }
    } catch (e) {
      print('EXCEPTION in sendInitialGreeting: $e');
      
      // Return a default greeting if there's an exception
      return {
        'greeting_message': 'Hi, how can I help you?',
        'thread_id': '',
      };
    }
  }

  static Future<List<Message>> fetchChatHistory(String partnerId, String userName) async {
    try {
      final url = '$baseUrl/messages/$userName/$partnerId';
      print('=== FETCHING CHAT HISTORY ===');
      print('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('History Response Status: ${response.statusCode}');
      print('History Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Parsed Response Data Type: ${responseData.runtimeType}');
        print('Parsed Response Data: $responseData');
        
        List<dynamic> messages;
        
        // Handle different possible response structures
        if (responseData is List) {
          messages = responseData;
          print('Response is a List with ${messages.length} items');
        } else if (responseData is Map && responseData.containsKey('messages')) {
          messages = responseData['messages'] as List<dynamic>;
          print('Response is a Map with messages array containing ${messages.length} items');
        } else if (responseData is Map && responseData.containsKey('data')) {
          messages = responseData['data'] as List<dynamic>;
          print('Response is a Map with data array containing ${messages.length} items');
        } else {
          print('Unexpected response structure: $responseData');
          messages = [];
        }
        
        print('Processing ${messages.length} messages...');
        
        final result = messages.map((msg) {
          print('Processing message: $msg');
          return Message(
            text: msg['content'] ?? msg['message'] ?? msg['text'] ?? '',
            isUser: msg['role'] == 'user' || msg['is_user'] == true,
            timestamp: DateTime.parse(msg['timestamp'] ?? msg['created_at'] ?? DateTime.now().toIso8601String()),
          );
        }).toList();
        
        print('Returning ${result.length} messages');
        return result;
      } else {
        print('ERROR: Failed to fetch chat history - ${response.statusCode}');
        print('Error Body: ${response.body}');
        throw Exception('Failed to fetch chat history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION in fetchChatHistory: $e');
      throw Exception('Network error: $e');
    }
  }
} 