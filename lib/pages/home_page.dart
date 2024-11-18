import 'package:flutter/material.dart';
import 'package:se_wmp_project/pages/courses_page.dart';
import 'package:se_wmp_project/pages/practice_page.dart'; // Assuming you have a PracticePage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'), // Title for the AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the PracticePage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PracticePage()),
                );
              },
              child: const Text('Go to Practice'),
            ),
            const SizedBox(height: 20), // Space between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to the CoursesPage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CoursesPage()),
                );
              },
              child: const Text('Go to Courses'),
            ),
          ],
        ),
      ),
    );
  }
}
