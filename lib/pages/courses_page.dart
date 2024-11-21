import 'package:flutter/material.dart';
import 'course_detail_page.dart';

class CoursesPage extends StatelessWidget {
  final List<Map<String, List<Map<String, String>>>> courses = [
    {
      "Course1": [
        {"word1": "Meaning of word1"},
        {"word2": "Meaning of word2"},
        {"word3": "Meaning of word3"},
      ]
    },
    {
      "Course2": [
        {"word4": "Meaning of word4"},
        {"word5": "Meaning of word5"},
        {"word6": "Meaning of word6"},
      ]
    },
    {
      "Course3": [
        {"word7": "Meaning of word7"},
        {"word8": "Meaning of word8"},
        {"word9": "Meaning of word9"},
      ]
    },
  ];

  CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Courses")),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          // Extract course name and word list
          String courseName = courses[index].keys.first;
          List<Map<String, String>> words = courses[index][courseName]!;

          return ListTile(
            title: Text(courseName),
            onTap: () {
              // Navigate to CourseDetailPage with courseName and word list
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailPage(
                    courseName: courseName,
                    words: words,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
