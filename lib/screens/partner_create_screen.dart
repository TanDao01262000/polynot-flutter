import 'package:flutter/material.dart';
import '../models/partner.dart';

class PartnerCreateScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController personalityController = TextEditingController();
  final TextEditingController backgroundController = TextEditingController();
  final TextEditingController communicationStyleController = TextEditingController();
  final TextEditingController expertiseController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();

  PartnerCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your partner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'AI Role (e.g., barista, language tutor)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Scenario',
                border: OutlineInputBorder(),
                hintText: 'e.g., Ordering coffee at a shop, One-on-one tutoring session',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: personalityController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Personality',
                border: OutlineInputBorder(),
                hintText: 'Describe the partner\'s personality and character traits',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: backgroundController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Background',
                border: OutlineInputBorder(),
                hintText: 'Describe the partner\'s background and experience',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: communicationStyleController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Communication Style',
                border: OutlineInputBorder(),
                hintText: 'How does this partner communicate?',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: expertiseController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Expertise',
                border: OutlineInputBorder(),
                hintText: 'What is this partner an expert in?',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: interestsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Interests',
                border: OutlineInputBorder(),
                hintText: 'What are this partner\'s interests and hobbies?',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Basic validation: ensure required fields are not empty
                  if (nameController.text.isNotEmpty &&
                      roleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty &&
                      personalityController.text.isNotEmpty &&
                      backgroundController.text.isNotEmpty &&
                      communicationStyleController.text.isNotEmpty &&
                      expertiseController.text.isNotEmpty &&
                      interestsController.text.isNotEmpty) {
                    
                    // Create a new Partner object with all required fields
                    final newPartner = Partner(
                      name: nameController.text,
                      aiRole: roleController.text,
                      scenario: descriptionController.text,
                      targetLanguage: 'English', // Default for now
                      userLevel: 'B1', // Default for now
                      personality: personalityController.text,
                      background: backgroundController.text,
                      communicationStyle: communicationStyleController.text,
                      expertise: expertiseController.text,
                      interests: interestsController.text,
                    );
                    
                    // Pop the screen and return the new partner
                    Navigator.pop(context, newPartner);
                  } else {
                    // Show an error message if required fields are empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Create Partner'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}