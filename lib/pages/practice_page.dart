import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:se_wmp_project/providers/language_provider.dart';
import 'package:se_wmp_project/providers/course_provider.dart';
import 'package:se_wmp_project/providers/user_provider.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  PracticePageState createState() => PracticePageState();
}

class PracticePageState extends State<PracticePage> {
  List<Map<String, dynamic>> _words = []; // List to hold all words
  Map<String, dynamic>? _currentWordData; // Current word being displayed
  final TextEditingController _controller = TextEditingController();
  String _feedbackMessage = '';
  bool _showNextWordButton = false;
  int _currentWordIndex = 0; // Index to track the current word
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchWords();
  }

  Future<void> _fetchWords() async {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    final selectedCourse =
        Provider.of<CourseProvider>(context, listen: false).selectedCourseId;
    final userId = Provider.of<UserProvider>(context, listen: false).uid;

    if (language == null || selectedCourse == null || userId == null) {
      setState(() {
        _currentWordData = null;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('courses')
          .doc(language)
          .collection('lessons')
          .doc(selectedCourse)
          .collection('words')
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Convert documents to list and shuffle
        _words = snapshot.docs.map((doc) => doc.data()).toList();
        _words.shuffle(); // Shuffle the words

        setState(() {
          _currentWordIndex = 0; // Start from the first word
          _currentWordData = _words[_currentWordIndex];
          _isLoading = false; // Stop loading when words are fetched
        });
      } else {
        print("No words found in the collection.");
        setState(() {
          _words = [];
          _currentWordData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching words: $e");
      setState(() {
        _words = [];
        _currentWordData = null;
        _isLoading = false;
      });
    }
  }

  void _checkAnswer() {
    final userInput = _controller.text.trim();
    final correctWord = _currentWordData?["word"] ?? "";

    print("User input: $userInput");
    print("Correct answer: $correctWord");

    bool isCorrect = userInput.toLowerCase() == correctWord.toLowerCase();

    setState(() {
      _feedbackMessage = isCorrect ? "Correct!" : "Incorrect. Try again.";
      _showNextWordButton = isCorrect;
    });
  }

  void _nextWord() {
    setState(() {
      _controller.clear();
      _feedbackMessage = '';
      _showNextWordButton = false;

      // Move to the next word
      _currentWordIndex++;
      if (_currentWordIndex >= _words.length) {
        _currentWordIndex = 0; // Reset to start if all words are used
      }
      _currentWordData = _words[_currentWordIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Practice")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator() // Show loading indicator
              : _currentWordData == null
                  ? const Text(
                      "No words available for this lesson.",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        const Text(
                          "Guess the Word:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _currentWordData?["meaning"] ?? '',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _controller,
                          onSubmitted: (_) => _checkAnswer(),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "Enter the word...",
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _checkAnswer,
                          child: const Text("Check Answer"),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _feedbackMessage,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                _showNextWordButton ? Colors.green : Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_showNextWordButton)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              onPressed: _nextWord, // Go to the next word
                              child: const Text("Next Word"),
                            ),
                          ),
                      ],
                    ),
        ),
      ),
    );
  }
}
