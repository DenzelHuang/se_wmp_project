import 'package:flutter/material.dart';
import 'word_detail_page.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseName;
  final List<Map<String, String>> words; // Word-meaning pairs

  const CourseDetailPage({
    super.key,
    required this.courseName,
    required this.words,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$courseName Vocabularies")),
      body: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          String word = words[index].keys.first;
          String meaning = words[index][word]!;

          return ListTile(
            title: Text(word),
            subtitle: const Text("Tap to see details"),
            onTap: () {
              // Navigate to WordDetailPage with the selected word and its meaning
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordDetailPage(
                    word: word,
                    meaning: meaning,
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
