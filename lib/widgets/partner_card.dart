import 'package:flutter/material.dart';
import '../models/partner.dart';
import '../screens/chat_screen.dart';

/* 
  Simple card view for partner selection
*/
class PartnerCard extends StatelessWidget {
  final Partner partner;

  const PartnerCard({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(partner: partner),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                partner.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(partner.role, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8),
              Text(partner.description, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
