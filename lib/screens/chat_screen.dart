import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/functional_button.dart';
import '../services/chat_service.dart';
import 'message_detail_screen.dart';

class ChatPage extends StatefulWidget {
  final String partnerName;
  
  const ChatPage({
    super.key,
    required this.partnerName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> messages = [
    Message(
      text: 'Hi, how can I help you?',
      isUser: false,
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Add user message immediately
    setState(() {
      messages.add(Message(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    try {
      // Send message to API
      final aiResponse = await ChatService.sendMessage(text);
      
      setState(() {
        messages.add(aiResponse);
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        messages.add(Message(
          text: 'Sorry, I\'m having trouble connecting right now. Please try again.',
          isUser: false,
        ));
        _isLoading = false;
      });
      
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToMessageDetail(String messageText) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessageDetailPage(message: messageText),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partnerName),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _isLoading) {
                  // Show loading indicator
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('AI is typing...'),
                      ],
                    ),
                  );
                }
                
                final message = messages[index];
                return MessageBubble(
                  message: message,
                  onTap: message.isUser
                      ? () => _navigateToMessageDetail(message.text)
                      : null,
                );
              },
            ),
          ),
          const Divider(height: 10),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FunctionalButton(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Enter message',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          ),
                          style: const TextStyle(fontSize: 15),
                          onSubmitted: (_) => _sendMessage(),
                          enabled: !_isLoading, // Disable input while loading
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isLoading ? null : _sendMessage,
                        icon: const Icon(Icons.send),
                        color: Colors.tealAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 