import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:se_wmp_project/providers/language_provider.dart';
import 'package:se_wmp_project/widgets/app_drawer.dart';
import 'word_detail_page.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  DictionaryPageState createState() => DictionaryPageState();
}

class DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _wordsList = [];
  List<Map<String, dynamic>> _filteredWordsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAndCreateDictionary();
  }

  Future<void> _checkAndCreateDictionary() async {
    try {
      final user = 'admin'; // Replace with actual current user logic
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      final selectedLanguage = languageProvider.selectedLanguage;

      // Reference to the user's dictionary document
      final userDictionariesRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user)
          .collection('dictionaries')
          .doc(selectedLanguage);

      final docSnapshot = await userDictionariesRef.get();

      if (!docSnapshot.exists) {
        // The user does not have a dictionary; create one using sample data
        final sampleDocSnapshot = await FirebaseFirestore.instance
            .collection('SampleDictionaries')
            .doc(selectedLanguage)
            .get();

        if (sampleDocSnapshot.exists) {
          final sampleData = sampleDocSnapshot.data()!;

          // Set the main dictionary document (metadata)
          await userDictionariesRef.set({
            'name': sampleData['name'],
            'isShared': false,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Reference to the 'words' subcollection in the sample dictionary
          final sampleWordsCollectionRef =
              sampleDocSnapshot.reference.collection('words');

          // Reference to the 'words' subcollection in the user's dictionary
          final wordsCollectionRef = userDictionariesRef.collection('words');

          // Copy each word document from the sample to the user's dictionary
          final wordsSnapshot = await sampleWordsCollectionRef.get();
          for (var wordDoc in wordsSnapshot.docs) {
            final wordData = wordDoc.data();
            if (wordData != null) {
              await wordsCollectionRef.add({
                'word': wordData['word'],
                'meaning': wordData['meaning'],
              });
            }
          }
        } else {
          print(
              "Error: Sample dictionary not found for the selected language.");
        }
      }
      // Fetch the words list after checking and potentially creating the dictionary
      _fetchWordsList();
    } catch (error) {
      print("Error checking and creating dictionary: $error");
    }
  }

  Future<void> _fetchWordsList() async {
    try {
      final user = 'admin'; // Temporary user for debugging purposes
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      final selectedLanguage = languageProvider.selectedLanguage;

      final userDictionaryRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user)
          .collection('dictionaries')
          .doc(selectedLanguage);

      final docSnapshot = await userDictionaryRef.get();

      if (docSnapshot.exists) {
        // Fetch the 'words' subcollection for the dictionary
        final wordsSnapshot = await userDictionaryRef.collection('words').get();

        if (wordsSnapshot.docs.isNotEmpty) {
          final List<Map<String, dynamic>> words =
              wordsSnapshot.docs.map((doc) {
            return {
              "id": doc.id,
              "word": doc["word"] as String,
              "meaning": doc["meaning"] as String,
            };
          }).toList();

          setState(() {
            _wordsList = words;
            _filteredWordsList = _wordsList;
            _isLoading = false;
          });
        } else {
          setState(() {
            _wordsList = [];
            _filteredWordsList = [];
            _isLoading = false;
          });
        }
      } else {
        print("User dictionary does not exist.");
        setState(() {
          _wordsList = [];
          _filteredWordsList = [];
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching words list: $error");
    }
  }

  void _filterWords(String query) {
    final filteredList = _wordsList
        .where((wordEntry) =>
            wordEntry["word"]!.toLowerCase().contains(query.toLowerCase()) ||
            wordEntry["meaning"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _filteredWordsList = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dictionary")),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterWords,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search for a word or meaning...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _filteredWordsList.isEmpty
                  ? const Center(child: Text("No words found"))
                  : ListView.builder(
                      itemCount: _filteredWordsList.length,
                      itemBuilder: (context, index) {
                        final wordEntry = _filteredWordsList[index];
                        return ListTile(
                          title: Text(wordEntry["word"]!),
                          subtitle: Text("Meaning: ${wordEntry["meaning"]}"),
                          onTap: () {
                            // Navigate to the WordDetailPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WordDetailPage(
                                  word: wordEntry["word"]!,
                                  meaning: wordEntry["meaning"]!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
