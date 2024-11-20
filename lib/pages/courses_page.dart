import 'package:flutter/material.dart';

// Course Detail Page to show words in a course
class CourseDetailPage extends StatelessWidget {
  final String courseName;
  final List<String> words;

  const CourseDetailPage({
    super.key,
    required this.courseName,
    required this.words,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$courseName Words")),
      body: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(words[index]),
          );
        },
      ),
    );
  }
}

// Courses Page to list all courses
class CoursesPage extends StatelessWidget {
  final List<Map<String, List<String>>> courses = [
    {
      "Course1": ["word1", "word2", "word3"]
    },
    {
      "Course2": ["word4", "word5", "word6"]
    },
    {
      "Course3": ["word7", "word8", "word9"]
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
          String courseName = courses[index].keys.first;
          List<String> words = courses[index][courseName]!;

          return ListTile(
            title: Text(courseName),
            onTap: () {
              // Navigate to CourseDetailPage
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
