import 'package:polynot_aipartner/services/chat_service.dart';

void main() async {
  try {
    final messages = await ChatService.fetchChatHistory("abc123");
    print('Fetched ${messages.length} messages:');
    for (var msg in messages) {
      print('${msg.isUser ? "User" : "AI"}: ${msg.text}');
    }
  } catch (e) {
    print('Error fetching chat history: $e');
  }
} 