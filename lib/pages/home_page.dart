import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:se_wmp_project/pages/courses_page.dart';
import 'package:se_wmp_project/providers/course_provider.dart';
import 'package:se_wmp_project/providers/user_provider.dart';
import 'package:se_wmp_project/widgets/app_drawer.dart';
import 'package:se_wmp_project/providers/language_provider.dart';
import 'package:se_wmp_project/pages/practice_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the LanguageProvider to get the current selected language
    final languageProvider = Provider.of<LanguageProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final selectedCourseTitle = courseProvider.selectedCourseTitle;

    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display the current selected language
            const Text(
              "Selected Language:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              languageProvider.selectedLanguage, // Show the selected language
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Button to open the language selection dialog
            ElevatedButton(
              onPressed: () {
                _showLanguageSelectionDialog(context);
              },
              child: const Text("Change Language"),
            ),

            const SizedBox(height: 30),

            // Display the current selected language
            const Text(
              "Selected Course:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              selectedCourseTitle ?? "No course selected",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Button to navigate to the course page to select a course
            ElevatedButton(
              onPressed: () {
                // Navigate to the courses page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoursesPage()),
                );
              },
              child: const Text("Select a Course"),
            ),

            const SizedBox(height: 30),

            // Button to navigate to the Practice page
            ElevatedButton(
              child: const Text("Practice Now"),
              onPressed: () {
                final courseProvider =
                    Provider.of<CourseProvider>(context, listen: false);

                if (courseProvider.selectedCourseId == null) {
                  // Show a message if no course is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Select a course in the Courses Page to begin practicing.",
                        style: TextStyle(fontSize: 16),
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  // Navigate to the PracticePage if a course is selected
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PracticePage(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show a dialog to select a new language
  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option to select French
              ListTile(
                title: const Text("French"),
                onTap: () {
                  Provider.of<LanguageProvider>(context, listen: false)
                      .changeLanguage("French"); // Change to French
                  Navigator.pop(context); // Close the dialog
                },
              ),
              // Option to select Japanese
              ListTile(
                title: const Text("Japanese"),
                onTap: () {
                  Provider.of<LanguageProvider>(context, listen: false)
                      .changeLanguage("Japanese"); // Change to Japanese
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
