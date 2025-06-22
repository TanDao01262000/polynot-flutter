import 'package:flutter/material.dart';
import '../models/partner.dart';
import '../widgets/partner_card.dart';
import './partner_create_screen.dart';

class PartnerSelectScreen extends StatefulWidget {
  const PartnerSelectScreen({super.key});

  @override
  State<PartnerSelectScreen> createState() => _PartnerSelectScreenState();
}

class _PartnerSelectScreenState extends State<PartnerSelectScreen> {
  // The list is now a mutable state variable
  final List<Partner> partnerList = [
    Partner(
      name: 'Sarah',
      role: 'Barista',
      description: 'Practice ordering coffee and making small talk',
    ),
    Partner(
      name: 'Michael',
      role: 'HR Manager',
      description: 'Prepare for job interviews with common questions',
    ),
    Partner(
      name: 'Emma',
      role: 'Date Partner',
      description: 'Simulate a first date conversation',
    ),
    // New partners
    Partner(
      name: 'David',
      role: 'Tour Guide',
      description: 'Practice asking for directions and local recommendations',
    ),
    Partner(
      name: 'Lisa',
      role: 'Language Instructor',
      description: 'Improve your English through casual conversation',
    ),
    Partner(
      name: 'James',
      role: 'Corporate Executive',
      description: 'Practice professional business meetings and negotiations',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a partner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: partnerList.length,
                itemBuilder: (context, index) {
                  return PartnerCard(partner: partnerList[index]);
                },
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newPartner = await Navigator.push<Partner>(
            context,
            MaterialPageRoute(
              builder: (context) => PartnerCreateScreen(),
            ),
          );

          if (newPartner != null) {
            setState(() {
              partnerList.add(newPartner);
            });
          }
        },
        label: const Text('Create your own partner'),
      ),
    );
  }
}