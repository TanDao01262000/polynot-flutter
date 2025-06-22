import 'package:flutter/material.dart';
import '../models/partner.dart';

class PartnerCreateScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  PartnerCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your partner'),
      ),
      body: Padding(
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
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Basic validation: ensure fields are not empty
                  if (nameController.text.isNotEmpty &&
                      roleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    // Create a new Partner object
                    final newPartner = Partner(
                      name: nameController.text,
                      role: roleController.text,
                      description: descriptionController.text,
                    );
                    // Pop the screen and return the new partner
                    Navigator.pop(context, newPartner);
                  } else {
                    // Optional: show an error message if fields are empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all fields.'),
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