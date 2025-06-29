import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';

class ChatService {
  // Get API configuration from environment variables
  static String get baseUrl => dotenv.env['GCP_API_ENDPOINT'] ?? '';
  
  // Hardcoded bearer token for demo, make sure to place your GCP token here
  static const String bearerToken = 'eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg4MjUwM2E1ZmQ1NmU5ZjczNGRmYmE1YzUwZDdiZjQ4ZGIyODRhZTkiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXpwIjoiNjE4MTA0NzA4MDU0LTlyOXMxYzRhbGczNmVybGl1Y2hvOXQ1Mm4zMm42ZGdxLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiYXVkIjoiNjE4MTA0NzA4MDU0LTlyOXMxYzRhbGczNmVybGl1Y2hvOXQ1Mm4zMm42ZGdxLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTE0NjgwODY3MzEwMjUzNzQzODgxIiwiaGQiOiJwb2x5bm90LmFpIiwiZW1haWwiOiJ0YW5AcG9seW5vdC5haSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoiQkZ6WlN6cFN5MHM1RkdibEMyRnZ3QSIsIm5iZiI6MTc1MTIzMTg4MiwiaWF0IjoxNzUxMjMyMTgyLCJleHAiOjE3NTEyMzU3ODIsImp0aSI6IjljMDFlNzQ0ZDZkNTliNDY4NWFmNDRmMDY2OGFjNDg3ZTJjNjc2N2EifQ.nysJkJtP9RskT8p7ZMhs08u3otQfmqUrMzWGd3d-QbhWFBKm4q-vu0jViCyUly6JFxZeWo887rWdPu2OaT532MZFV90ym8nFwcxI6EcddC1X3Eki67xTNfOPVcvrnZrckDR0X2NZb7gOMsbVq6De6BTY5jkzE33SO20A6Acdg_3aQOlRo0oddfN-KlDxr_3OJ1lTMuL7JwS9S6kD0-oCC5Jp_iwdScUq-JQazjF_-VgKkxobEnRYi2FIGanmOYT_oqd0XXxe9zuIed5orpFced2aFtlzNtqW2uNUXZcI-wS7bp3l1OHKs6sSPyZfXsUDp-ZZ_IHY0iF8-fjvpCQf2Q';
  
  // Demo values - hardcoded for simplicity
  static const String userName = 'test_user';
  static const String scenarioId = 'coffee_shop';
  static const String threadId = 'abc124';

  static Future<Message> sendMessage(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode({
          'thread_id': threadId,
          'user_input': userInput,
          'user_name': userName,
          'scenario_id': scenarioId,
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
        
        throw Exception();
      }
    } catch (e) {
      print('EXCEPTION: $e');
      print('Exception Type: ${e.runtimeType}');
      print('Stack Trace: ${StackTrace.current}');
      
      throw Exception();
    }
  }

  // Fetch message but not used for now
  // static Future<List<Message>> fetchChatHistory() async {
  //   try {
  //     print('=== FETCHING CHAT HISTORY ===');
  //     print('URL: $baseUrl/chat/history?thread_id=$threadId');

  //     final response = await http.get(
  //       Uri.parse('$baseUrl/chat/history?thread_id=$threadId'),
  //       headers: {
  //         'Authorization': 'Bearer $bearerToken',
  //       },
  //     );

  //     print('History Response Status: ${response.statusCode}');
  //     print('History Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final List<dynamic> messages = data['messages'] ?? [];
        
  //       return messages.map((msg) => Message(
  //         text: msg['text'] ?? '',
  //         isUser: msg['is_user'] ?? false,
  //         timestamp: DateTime.parse(msg['timestamp'] ?? DateTime.now().toIso8601String()),
  //       )).toList();
  //     } else {
  //       print('ERROR: Failed to fetch chat history - ${response.statusCode}');
  //       print('Error Body: ${response.body}');
        
  //       throw Exception('Failed to fetch chat history: ${response.statusCode} - ${response.body}');
  //     }
  //   } catch (e) {
  //     print('EXCEPTION in fetchChatHistory: $e');
  //     throw Exception('Network error: $e');
  //   }
  // }
} 