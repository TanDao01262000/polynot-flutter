import 'package:flutter/material.dart';
import '../widgets/main_option_card.dart';
import './partner_selection_screen.dart';
import './vocabulary_generation_screen.dart';

class MainScreen extends StatelessWidget{
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Partner'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MainOptionCard(
              text: 'Have a conversation',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartnerSelectScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            MainOptionCard(
              text: 'Generate Vocabulary',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VocabularyGenerationScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            MainOptionCard(text: 'Imporve your accent', onTap: () {}),
          ],
        ),
      ),
    );
  } 
}