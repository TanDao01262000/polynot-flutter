import 'package:flutter/material.dart';
import '../models/partner.dart';
import '../widgets/partner_card.dart';

class PartnerSelectScreen extends StatelessWidget {

  final List<Partner> partnerList = [
    Partner(
      name: 'Coffee Shop Barista',
      role: 'Barista',
      description: 'Practice ordering coffee and making small talk',
    ),
    Partner(
      name: 'Job Interviewer',
      role: 'HR Manager',
      description: 'Prepare for job interviews with common questions',
    ),
    Partner(
      name: 'First Date',
      role: 'Date Partner',
      description: 'Simulate a first date conversation',
    ),
    // New partners
    Partner(
      name: 'Travel Guide',
      role: 'Tour Guide',
      description: 'Practice asking for directions and local recommendations',
    ),
    Partner(
      name: 'English Teacher',
      role: 'Language Instructor',
      description: 'Improve your English through casual conversation',
    ),
    Partner(
      name: 'Business Client',
      role: 'Corporate Executive',
      description: 'Practice professional business meetings and negotiations',
    ),
  ];

  PartnerSelectScreen({super.key});  // Remove const since we have non-const list

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a partner'),
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
          SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          print('I have click on floating button');
        },
        label: Text('Create your own partner'),
      ),
    );
  }
}