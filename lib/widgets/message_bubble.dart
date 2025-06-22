import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onTap;

  const MessageBubble({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    final bubble = Container(
      margin: EdgeInsets.only(
        top: 6,
        bottom: 6,
        left: isUser ? 60 : 8,
        right: isUser ? 8 : 60,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? Colors.teal : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isUser ? Colors.white : Colors.white,
        ),
      ),
    );

    return isUser
        ? GestureDetector(
            onTap: onTap,
            child: bubble,
          )
        : bubble;
  }
} 