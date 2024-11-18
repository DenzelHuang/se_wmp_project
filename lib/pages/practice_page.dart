import 'package:flutter/material.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Practice Page")),
      body: const Padding(
        padding: EdgeInsets.all(16.0), // Margin for the entire content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0), // Margin below the first Text
              child: Text(
                "This is the first text view",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0), // Margin below the second Text
              child: Text(
                "This is the second text view",
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter some text',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
