import 'package:flutter/material.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Practice Page")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30), // Adds space at the top

            // "Guess the Word" title
            Text(
              "Guess the Word:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Placeholder for the meaning (for the user to guess the word)
            Text(
              "Word", // Placeholder
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Text Field for the user to input their guess (just a placeholder for now)
            TextField(
              decoration: InputDecoration(
                hintText: "Your guess...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Placeholder Button to check the answer
            ElevatedButton(
              onPressed: null, // Placeholder action, no functionality yet
              child: Text("Check Answer"),
            ),
          ],
        ),
      ),
    );
  }
}
