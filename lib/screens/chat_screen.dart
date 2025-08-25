import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../models/partner.dart';
import '../widgets/message_bubble.dart';
import '../widgets/functional_button.dart';
import '../services/chat_service.dart';
import '../providers/user_provider.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // Auto-scroll to bottom when new messages are added
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      // Get current user from provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      final userName = currentUser?.userName ?? 'Kay'; // Fallback to Kay for testing
      
      // First, try to get initial greeting and thread_id
      final greetingResponse = await ChatService.sendInitialGreeting(
        partnerId: widget.partner.id,
        userName: userName,
      );
      
      // Try to fetch existing chat history using partner ID
      try {
        final chatHistory = await ChatService.fetchChatHistory(widget.partner.id, userName);
        if (chatHistory.isNotEmpty) {
          // We have existing messages, use them
          setState(() {
            messages.clear();
            messages.addAll(chatHistory);
            _isInitializing = false;
          });
          _scrollToBottom(); // Scroll to bottom after loading history
          return;
        }
      } catch (historyError) {
        print('No existing chat history found: $historyError');
        // Continue to show initial greeting
      }
      
      // No existing history, show initial greeting
      final greetingMessage = greetingResponse['greeting_message'] as String;
      setState(() {
        messages.clear();
        messages.add(Message(
          text: greetingMessage,
          isUser: false,
        ));
        _isInitializing = false;
      });
      _scrollToBottom(); // Scroll to bottom after showing greeting
    } catch (e) {
      // Fallback to local greeting if everything fails
      setState(() {
        messages.add(Message(
          text: 'Hi, how can I help you?',
          isUser: false,
        ));
        _isInitializing = false;
      });
      _scrollToBottom(); // Scroll to bottom after fallback
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
    _scrollToBottom(); // Scroll to bottom after adding user message

    try {
      // Get current user from provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      final userName = currentUser?.userName ?? 'Kay'; // Fallback to Kay for testing
      
      // Send message to API
      final aiResponse = await ChatService.sendMessage(
        text,
        partnerId: widget.partner.id,
        userName: userName,
      );
      
      setState(() {
        messages.add(aiResponse);
        _isLoading = false;
      });
      _scrollToBottom(); // Scroll to bottom after adding AI response
    } catch (e) {
      // Handle error
      setState(() {
        messages.add(Message(
          text: 'Sorry, I\'m having trouble connecting right now. Please try again.',
          isUser: false,
        ));
        _isLoading = false;
      });
      _scrollToBottom(); // Scroll to bottom after adding error message
      
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
    _scrollController.dispose();
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
                    controller: _scrollController,
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
                              Text('Typing...'),
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