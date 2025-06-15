import 'package:flutter/material.dart';

class MainOptionCard extends StatelessWidget{
  final String text;
  final VoidCallback onTap;

  const MainOptionCard({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40),
        color: Colors.grey[200],
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),

    );
  }
}