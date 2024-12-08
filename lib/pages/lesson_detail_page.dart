import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:se_wmp_project/pages/word_detail_page.dart';
import 'package:se_wmp_project/providers/language_provider.dart';
import 'package:se_wmp_project/providers/user_provider.dart';
import 'package:se_wmp_project/widgets/app_drawer.dart';

class LessonDetailPage extends StatefulWidget {
  final String lessonId;
  final String title;

  const LessonDetailPage({
    super.key,
    required this.lessonId,
    required this.title,
  });

  @override
  _LessonDetailPageState createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  List<Map<String, dynamic>> _wordsList = [];
  List<Map<String, dynamic>> _filteredWordsList = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWordsList();
    _searchController.addListener(_filterWords);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterWords);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchWordsList() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).uid;
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      final selectedLanguage = languageProvider.selectedLanguage;

      final lessonRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('courses')
          .doc(selectedLanguage)
          .collection('lessons')
          .doc(widget.lessonId);

      final wordsSnapshot = await lessonRef.collection('words').get();
      _wordsList = wordsSnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "word": doc["word"],
          "meaning": doc["meaning"],
        };
      }).toList();

      // Initialize the filtered list with all words
      _filteredWordsList = List.from(_wordsList);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching lesson details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterWords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWordsList = _wordsList.where((wordEntry) {
        return wordEntry["word"]?.toLowerCase().contains(query) == true ||
            wordEntry["meaning"]?.toLowerCase().contains(query) == true;
      }).toList();
    });
  }

  Future<void> _addWord(String word, String meaning) async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).uid;
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      final selectedLanguage = languageProvider.selectedLanguage;

      final lessonRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('courses')
          .doc(selectedLanguage)
          .collection('lessons')
          .doc(widget.lessonId)
          .collection('words');

      await lessonRef.add({
        'word': word,
        'meaning': meaning,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _fetchWordsList();
    } catch (e) {
      print("Error adding word: $e");
    }
  }

  Future<void> _editWord(
      String wordId, String newWord, String newMeaning) async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).uid;
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      final selectedLanguage = languageProvider.selectedLanguage;

      final wordRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('courses')
          .doc(selectedLanguage)
          .collection('lessons')
          .doc(widget.lessonId)
          .collection('words')
          .doc(wordId);

      await wordRef.update({
        'word': newWord,
        'meaning': newMeaning,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _fetchWordsList();
    } catch (e) {
      print("Error editing word: $e");
    }
  }

  Future<void> _deleteWord(String wordId) async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).uid;
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      final selectedLanguage = languageProvider.selectedLanguage;

      final wordRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('courses')
          .doc(selectedLanguage)
          .collection('lessons')
          .doc(widget.lessonId)
          .collection('words')
          .doc(wordId);

      await wordRef.delete();

      _fetchWordsList();
    } catch (e) {
      print("Error deleting word: $e");
    }
  }

  Future<void> _exportToJson() async {
    try {
      // Check if the list of words is empty
      if (_wordsList.isEmpty) {
        _showErrorDialog('Export Error', 'No data available to export.');
        return; // Exit the method if no data is available
      }

      // Check for permissions based on platform and Android version
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.isGranted ||
            await Permission.storage.isGranted) {
          // Permissions granted, continue
        } else {
          // Request permissions
          if (await Permission.manageExternalStorage.isGranted) {
            // Android 29+ - Manage external storage
            await Permission.manageExternalStorage.request();
          } else {
            // Lower Android versions - Storage permissions
            await [Permission.storage].request();
          }
        }
      }

      if (Platform.isIOS) {
        // iOS doesn't need explicit permission handling for file writing to documents or app support directories
        // Ensure your app's Info.plist has appropriate keys if you write to the photo library
      }

      // Allow user to pick a directory where the file will be saved
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        // User canceled the directory picker
        return; // Exit the method if the user cancels the selection
      }

      // Create a unique file name based on the current timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputFile =
          File('$selectedDirectory/dictionary_export_$timestamp.json');

      // Prepare the data to be exported in JSON format
      List<Map<String, dynamic>> exportData = _wordsList
          .map((word) => {'word': word['word'], 'meaning': word['meaning']})
          .toList();

      // Convert the list to a pretty-printed JSON string
      String jsonString =
          const JsonEncoder.withIndent('  ').convert(exportData);

      // Write the JSON string to the output file
      await outputFile.writeAsString(jsonString);

      // Show a success dialog indicating where the file was saved
      _showSuccessDialog('Export Successful',
          'The JSON file was exported to ${outputFile.path}');
    } catch (e) {
      // Catch any errors that occur during the export process and show an error dialog
      _showErrorDialog('Export Error', e.toString());
    }
  }

  Future<void> _importFromJson() async {
    try {
      // Request permissions
      await Permission.manageExternalStorage.request();

      // Use FilePicker to select a JSON file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Dictionary JSON File',
      );

      // Handle cancellation
      if (result == null) return;

      // Read the selected file
      File file = File(result.files.single.path!);
      String jsonString = await file.readAsString();

      // Parse JSON
      List<dynamic> importedWords = jsonDecode(jsonString);

      // Process imported words
      for (var wordData in importedWords) {
        String word = wordData['word'];
        String meaning = wordData['meaning'];

        // Check for duplicates
        bool wordExists = _wordsList.any((entry) => entry['word'] == word);

        if (wordExists) {
          // Find the existing word entry to display for comparison
          var existingEntry =
              _wordsList.firstWhere((entry) => entry['word'] == word);
          String existingMeaning = existingEntry['meaning'];

          // If the existing meaning matches the imported meaning, skip without showing the dialog
          if (existingMeaning == meaning) {
            continue; // Skip this word as it's the same
          }

          // Show dialog for duplicate handling with comparison
          bool? result = await _showDuplicateHandlingDialog(
              existingEntry['word'], existingMeaning, word, meaning);

          if (result == null) continue; // User canceled
          if (result) {
            await _replaceExistingWord(word, meaning); // Replace existing
          } else {
            continue; // Skip
          }
        } else {
          await _addImportedWord(word, meaning); // Add new word
        }
      }
      _fetchWordsList();
    } catch (e) {
      // Handle any errors that occur during the import process
      _showErrorDialog('Import Error', e.toString());
    }
  }

// Dialogs for error and success handling
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDuplicateHandlingDialog(
      String existingWord,
      String existingMeaning,
      String importedWord,
      String importedMeaning) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent closing without making a choice
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate Found: $existingWord'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Existing Entry:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Word: $existingWord'),
              Text('Meaning: $existingMeaning'),
              SizedBox(height: 10),
              Text('Imported Entry:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Word: $importedWord'),
              Text('Meaning: $importedMeaning'),
              SizedBox(height: 20),
              Text('Do you want to replace the existing entry or skip?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Skip
              child: Text('Skip'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Replace
              child: Text('Replace'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to replace an existing word
  Future<void> _replaceExistingWord(String word, String meaning) async {
    final userId = Provider.of<UserProvider>(context, listen: false).uid;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final selectedLanguage = languageProvider.selectedLanguage;

    final userLessonRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('courses')
        .doc(selectedLanguage)
        .collection('lessons')
        .doc(widget.lessonId);

    // Find and update the existing word
    final querySnapshot = await userLessonRef
        .collection('words')
        .where('word', isEqualTo: word)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update(
          {'meaning': meaning, 'updatedAt': FieldValue.serverTimestamp()});
    }
  }

// Helper method to add a word to Firestore
  Future<void> _addImportedWord(String word, String meaning) async {
    final userId = Provider.of<UserProvider>(context, listen: false).uid;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final selectedLanguage = languageProvider.selectedLanguage;

    final userLessonRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('courses')
        .doc(selectedLanguage)
        .collection('lessons')
        .doc(widget.lessonId);

    await userLessonRef.collection('words').add({
      'word': word,
      'meaning': meaning,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () {
              // Show a dialog to choose between import and export
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Import/Export'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Import from JSON'),
                          onTap: () {
                            Navigator.of(context).pop();
                            _importFromJson();
                          },
                        ),
                        ListTile(
                          title: const Text('Export to JSON'),
                          onTap: () {
                            Navigator.of(context).pop();
                            _exportToJson();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : _filteredWordsList.isEmpty
                  ? Center(child: Text("No words found"))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _filteredWordsList.length,
                        itemBuilder: (context, index) {
                          final wordEntry = _filteredWordsList[index];
                          return ListTile(
                            title: Text(wordEntry["word"] ?? "Unknown"),
                            subtitle:
                                Text(wordEntry["meaning"] ?? "No meaning"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        final wordController =
                                            TextEditingController(
                                                text: wordEntry["word"]);
                                        final meaningController =
                                            TextEditingController(
                                                text: wordEntry["meaning"]);

                                        return AlertDialog(
                                          title: const Text("Edit Word"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                controller: wordController,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: "Word"),
                                              ),
                                              TextField(
                                                controller: meaningController,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: "Meaning"),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (wordController
                                                        .text.isNotEmpty &&
                                                    meaningController
                                                        .text.isNotEmpty) {
                                                  _editWord(
                                                      wordEntry["id"]!,
                                                      wordController.text,
                                                      meaningController.text);
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: const Text("Save"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm Deletion"),
                                          content: const Text(
                                              "Are you sure you want to delete this word?"),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancel"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text("Delete"),
                                              onPressed: () {
                                                _deleteWord(wordEntry["id"]!);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              final wordController = TextEditingController();
              final meaningController = TextEditingController();

              return AlertDialog(
                title: const Text("Add New Word"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: wordController,
                      decoration: const InputDecoration(labelText: "Word"),
                    ),
                    TextField(
                      controller: meaningController,
                      decoration: const InputDecoration(labelText: "Meaning"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      if (wordController.text.isNotEmpty &&
                          meaningController.text.isNotEmpty) {
                        _addWord(wordController.text, meaningController.text);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Word',
      ),
    );
  }
}
