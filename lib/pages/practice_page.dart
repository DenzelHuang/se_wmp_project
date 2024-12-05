import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:se_wmp_project/providers/language_provider.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  PracticePageState createState() => PracticePageState();
}

class PracticePageState extends State<PracticePage> {
  // Separate course dictionaries for both languages
  final Map<String, List<Map<String, String>>> _courses = {
    "Japanese": [
      {
        "kanji": "林檎",
        "hiragana": "りんご",
        "katakana": "リンゴ",
        "definition": "A fruit that is red or green and keeps the doctor away."
      },
      {
        "kanji": "犬",
        "hiragana": "いぬ",
        "katakana": "イヌ",
        "definition": "A domesticated animal that is often a human's best friend."
      },
      {
        "kanji": "猫",
        "hiragana": "ねこ",
        "katakana": "ネコ",
        "definition": "A small domesticated carnivorous mammal with soft fur."
      },
      {
        "kanji": "車",
        "hiragana": "くるま",
        "katakana": "クルマ",
        "definition": "A four-wheeled vehicle used for transportation."
      }
    ],
    "French": [
      {
        "word": "pomme",
        "definition": "A fruit that is red or green and keeps the doctor away."
      },
      {
        "word": "chien",
        "definition": "A domesticated animal that is often a human's best friend."
      },
      {
        "word": "chat",
        "definition": "A small domesticated carnivorous mammal with soft fur."
      },
      {
        "word": "voiture",
        "definition": "A four-wheeled vehicle used for transportation."
      }
    ]
  };

  Map<String, String> _currentWordData = {};
  final TextEditingController _controller = TextEditingController();
  String _feedbackMessage = '';
  late bool _showNextWordButton = false;

  @override
  void initState() {
    super.initState();
    _pickRandomWord();
  }

  // Function to pick a random word that is not the current word
  void _pickRandomWord() {
    // Get the current selected language from the provider
    final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    List<Map<String, String>> currentCourse = _courses[language] ?? [];

    Map<String, String> newWord;
    do {
      newWord = (currentCourse..shuffle()).first;
    } while (newWord == _currentWordData);

    setState(() {
      _currentWordData = newWord;
      _controller.clear();
      _feedbackMessage = '';
      _showNextWordButton = false;
    });
  }

  // Function to check the user's guess
  void _checkAnswer() {
    final userInput = _controller.text.trim();
    final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    bool isCorrect = false;

    if (language == "Japanese") {
      isCorrect = userInput == _currentWordData["kanji"] ||
          userInput == _currentWordData["hiragana"] ||
          userInput == _currentWordData["katakana"];
    } else if (language == "French") {
      isCorrect = userInput == _currentWordData["word"];
    }

    setState(() {
      _feedbackMessage = _getFeedbackMessage(language, isCorrect);
      _showNextWordButton = isCorrect; // Show button if correct
    });
  }

  // Get the feedback message based on the selected language
  String _getFeedbackMessage(String language, bool isCorrect) {
    final localizedText = _getLocalizedText(language);
    return isCorrect
        ? localizedText["feedbackCorrect"] ?? "Correct!"
        : localizedText["feedbackIncorrect"] ?? "Incorrect. Try again.";
  }

  // Get localized text based on the selected language
  Map<String, String> _getLocalizedText(String language) {
    switch (language) {
      case "Japanese":
        return {
          "title": "単語を当ててください (Guess the Word):",
          "hintText": "単語を入力してください... (Enter the word...)",
          "checkAnswerButton": "答えを確認する (Check Answer)",
          "nextWordButton": "次の単語へ (Next Word)",
          "feedbackCorrect": "正解です! (Correct!)",
          "feedbackIncorrect": "不正解です。もう一度試してください。 (Incorrect. Try again.)",
        };
      case "French":
        return {
          "title": "Devinez le mot: (Guess the Word)",
          "hintText": "Entrez le mot... (Enter the word...)",
          "checkAnswerButton": "Vérifier la réponse (Check Answer)",
          "nextWordButton": "Mot suivant (Next Word)",
          "feedbackCorrect": "Correcte! (Correct!)",
          "feedbackIncorrect": "Incorrect! Essayez encore. (Try again)",
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current selected language from the provider
    final language = Provider.of<LanguageProvider>(context).selectedLanguage;
    final localizedText = _getLocalizedText(language);

    return Scaffold(
      appBar: AppBar(title: Text(localizedText["title"] ?? "Practice")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Title of the practice page
              Text(
                localizedText["title"] ?? "Practice",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Placeholder for the meaning (for the user to guess the word)
              Text(
                _currentWordData["definition"] ?? '',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Text Field for the user to input their guess
              TextField(
                controller: _controller,
                onSubmitted: (_) => _checkAnswer(), // Trigger _checkAnswer on Enter key
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: localizedText["hintText"] ?? "Enter the word...",
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey), // Gray border when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor), // Gray border when focused
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Button to check the answer
              ElevatedButton(
                onPressed: _checkAnswer,
                child: Text(localizedText["checkAnswerButton"] ?? "Check Answer"),
              ),
              const SizedBox(height: 20),

              // Feedback message for the user
              Text(
                _feedbackMessage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _showNextWordButton
                      ? Colors.green
                      : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

              // Show the "Next Word" button only if the answer is correct
              if (_showNextWordButton)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: _pickRandomWord,
                    child: Text(localizedText["nextWordButton"] ?? "Next Word"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
