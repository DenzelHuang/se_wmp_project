import 'package:flutter/material.dart';
import 'package:se_wmp_project/widgets/app_drawer.dart';
import 'word_detail_page.dart';

class DictionaryPage extends StatelessWidget {
  final List<Map<String, String>> vocabularyList = [
    {"word": "こんにちは", "meaning": "Hello"},
    {"word": "ありがとう", "meaning": "Thank you"},
    {"word": "さようなら", "meaning": "Goodbye"},
  ];

  DictionaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dictionary")),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: vocabularyList.length,
        itemBuilder: (context, index) {
          String word = vocabularyList[index]["word"]!;
          String meaning = vocabularyList[index]["meaning"]!;

          return ListTile(
            title: Text(word),
            subtitle: const Text("Tap to see details"),
            onTap: () {
              // Navigate to WordDetailPage with word and meaning
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
