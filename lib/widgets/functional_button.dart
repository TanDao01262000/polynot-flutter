import 'package:flutter/material.dart';

class FunctionalButton extends StatefulWidget {
  const FunctionalButton({super.key});

  @override
  State<FunctionalButton> createState() => _FunctionalButtonState();
}

class _FunctionalButtonState extends State<FunctionalButton> {
  bool _isWidgetShow = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isWidgetShow = !_isWidgetShow;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black54,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('...', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (_isWidgetShow) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                print('Clicked on Recent vocab button');
              },
              child: const Text('Recent Vocab'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                print('Clicked on Response for me button');
              },
              child: const Text('Response for me'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                print('Clicked on Keep talking button');
              },
              child: const Text('Keep talking'),
            ),
          ],
        ],
      ),
    );
  }
} 