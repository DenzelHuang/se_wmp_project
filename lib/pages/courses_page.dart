import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:se_wmp_project/providers/language_provider.dart';
import 'package:se_wmp_project/providers/user_provider.dart';
import 'package:se_wmp_project/widgets/app_drawer.dart';
import 'lesson_detail_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  CoursesPageState createState() => CoursesPageState();
}

class CoursesPageState extends State<CoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _lessonTitleController = TextEditingController();
  final TextEditingController _addLessonTitleController =
      TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _lessonsList = [];
  List<Map<String, dynamic>> _filteredLessonsList = [];

  @override
  void initState() {
    super.initState();
    _checkAndCreateCourses();
  }

  Future<void> _checkAndCreateCourses() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).uid;
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      final selectedLanguage = languageProvider.selectedLanguage;

      // Reference to the user's courses collection
      final userCoursesRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('courses')
          .doc(selectedLanguage)
          .collection('lessons');

      // Reference to the sample courses collection
      final sampleLessonsRef = FirebaseFirestore.instance
          .collection('SampleCourses')
          .doc(selectedLanguage)
          .collection('lessons');

      final sampleLessonsSnapshot = await sampleLessonsRef.get();

      if (sampleLessonsSnapshot.docs.isNotEmpty) {
        for (var lessonDoc in sampleLessonsSnapshot.docs) {
          final lessonData = lessonDoc.data();

          // Create the user's lesson document if it doesn't exist
          final userLessonRef = userCoursesRef.doc(lessonDoc.id);
          final lessonExists = (await userLessonRef.get()).exists;

          if (!lessonExists) {
            await userLessonRef.set({
              'title': lessonData['title'],
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });

            // Copy the words subcollection to the user's lesson
            final sampleWordsCollectionRef =
                lessonDoc.reference.collection('words');
            final userWordsCollectionRef = userLessonRef.collection('words');

            final wordsSnapshot = await sampleWordsCollectionRef.get();
            for (var wordDoc in wordsSnapshot.docs) {
              final wordData = wordDoc.data();
              await userWordsCollectionRef.add({
                'word': wordData['word'],
                'meaning': wordData['meaning'],
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }
      } else {
        print("Error: Sample lessons not found for the selected language.");
      }
      _fetchLessonsList();
    } catch (error) {
      print("Error checking and creating courses: $error");
    }
  }

  Future<void> _fetchLessonsList() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).uid;
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      final selectedLanguage = languageProvider.selectedLanguage;

      // Reference to the user's lessons collection
      final userLessonsRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('courses')
          .doc(selectedLanguage)
          .collection('lessons');

      // Fetch all lessons for the selected language
      final lessonsSnapshot = await userLessonsRef.get();

      if (lessonsSnapshot.docs.isNotEmpty) {
        final List<Map<String, dynamic>> lessons =
            lessonsSnapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "title": doc["title"],
            "createdAt": (doc["createdAt"] as Timestamp).toDate(),
            "updatedAt": (doc["updatedAt"] as Timestamp).toDate(),
          };
        }).toList();

        setState(() {
          _lessonsList = lessons;
          _filteredLessonsList = _lessonsList; // Initialize the filtered list
          _isLoading = false;
        });
      } else {
        setState(() {
          _lessonsList = [];
          _filteredLessonsList = [];
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching lessons list: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterLessonsList(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        _filteredLessonsList =
            _lessonsList; // Reset to full list if keyword is empty
      } else {
        _filteredLessonsList = _lessonsList.where((lesson) {
          return lesson["title"].toLowerCase().contains(keyword.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _addLesson() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).uid;
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      final selectedLanguage = languageProvider.selectedLanguage;

      final userLessonsRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('courses')
          .doc(selectedLanguage)
          .collection('lessons');

      if (_addLessonTitleController.text.isNotEmpty) {
        await userLessonsRef.add({
          'title': _addLessonTitleController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _fetchLessonsList(); // Refresh the list after adding
      } else {
        print(
            "Lesson title cannot be empty."); // Optional: add a dialog or snackbar for this
      }
    } catch (error) {
      print("Error adding lesson: $error");
    }
  }

  Future<void> _editLesson(String id, String newTitle) async {
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
        .doc(id);

    await userLessonRef.update({
      'title': newTitle,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    _fetchLessonsList();
  }

  Future<void> _deleteLesson(String id) async {
    try {
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
          .doc(id);

      // Reference to the words subcollection
      final wordsCollectionRef = userLessonRef.collection('words');

      // Delete all documents within the words subcollection
      final wordsSnapshot = await wordsCollectionRef.get();
      for (var wordDoc in wordsSnapshot.docs) {
        await wordDoc.reference.delete();
      }

      // Now delete the main lesson document
      await userLessonRef.delete();
      print(
          "Lesson with ID $id and its words subcollection deleted successfully.");

      _fetchLessonsList(); // Refresh the lessons list after deletion
    } catch (error) {
      print("Error deleting lesson or its subcollection: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course"),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterLessonsList,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search for a lesson...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _filteredLessonsList.isEmpty
                  ? const Center(child: Text("No lessons found"))
                  : ListView.builder(
                      itemCount: _filteredLessonsList.length,
                      itemBuilder: (context, index) {
                        final lessonEntry = _filteredLessonsList[index];
                        return ListTile(
                          title: Text(lessonEntry["title"]!),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _lessonTitleController.text =
                                      lessonEntry["title"]!;
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Edit Lesson"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller:
                                                  _lessonTitleController,
                                              decoration: const InputDecoration(
                                                labelText: "Title",
                                              ),
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
                                              _editLesson(
                                                lessonEntry["id"],
                                                _lessonTitleController.text,
                                              );
                                              Navigator.of(context).pop();
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
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Delete Lesson"),
                                        content: const Text(
                                            "Are you sure you want to delete this lesson?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await _deleteLesson(
                                                  lessonEntry["id"]);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Delete"),
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LessonDetailPage(
                                  lessonId: lessonEntry["id"],
                                  title: lessonEntry["title"],
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
              return AlertDialog(
                title: const Text("Add New Lesson"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _addLessonTitleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_addLessonTitleController.text.isNotEmpty) {
                        await _addLesson(); // Call the method to add the lesson
                        _addLessonTitleController
                            .clear(); // Clear the input field
                        Navigator.of(context).pop(); // Close the dialog
                      } else {
                        // Optionally, show an error message if the title is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Lesson title cannot be empty"),
                          ),
                        );
                      }
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
