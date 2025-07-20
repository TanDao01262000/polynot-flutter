import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/partner.dart';
import '../widgets/message_bubble.dart';
import '../widgets/functional_button.dart';
import '../services/chat_service.dart';
import 'message_detail_screen.dart';

class ChatPage extends StatefulWidget {
  final Partner partner;
  
  const ChatPage({
    super.key,
    required this.partner,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final chatHistory = await ChatService.fetchChatHistory(widget.partner.id);
      setState(() {
        messages.clear();
        messages.addAll(chatHistory);
        _isInitializing = false;
      });
    } catch (e) {
      // If no chat history exists, send an initial greeting to the backend
      try {
        final initialGreeting = await ChatService.sendInitialGreeting(
          widget.partner.id,
          partnerName: widget.partner.name,
          partnerRole: widget.partner.role,
          partnerDescription: widget.partner.description,
        );
        setState(() {
          messages.clear();
          messages.add(initialGreeting);
          _isInitializing = false;
        });
      } catch (greetingError) {
        // Fallback to local greeting if backend greeting fails
        setState(() {
          messages.add(Message(
            text: 'Hi, how can I help you?',
            isUser: false,
          ));
          _isInitializing = false;
        });
      }
    }
  }

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
      final aiResponse = await ChatService.sendMessage(text, partnerId: widget.partner.id);
      
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
        title: Text(widget.partner.name),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isInitializing
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
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