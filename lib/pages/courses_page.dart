import 'package:flutter/material.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List of languages
    final languages = ['French', 'Japanese', 'German', 'Mandarin'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Implement navigation or action for each language
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${languages[index]} course selected')),
                  );
                },
                child: Text(languages[index]),
              ),
              const SizedBox(height: 10), // Space between buttons
            ],
          );
        },
      ),
    );
  }
}
