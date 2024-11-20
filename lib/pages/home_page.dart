import 'package:flutter/material.dart';
import 'package:se_wmp_project/pages/courses_page.dart';
import 'package:se_wmp_project/pages/practice_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary placeholders for selected language and course
    const String selectedLanguage = "Japanese";
    const String selectedCourse = "Course1";

    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display the current selected language
            const Text(
              "Selected Language:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              selectedLanguage,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Display the current selected course
            const Text(
              "Selected Course:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              selectedCourse,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Button to practice
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                "Practice Now",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PracticePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
