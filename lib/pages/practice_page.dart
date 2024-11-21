import 'package:flutter/material.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  PracticePageState createState() => PracticePageState();
}

class PracticePageState extends State<PracticePage> {
  // Sample dictionary with Japanese words
  final List<Map<String, String>> _dictionary = [
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
  ];

  Map<String, String> _currentWordData = {
    "kanji": "",
    "hiragana": "",
    "katakana": "",
    "definition": ""
  };
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
    Map<String, String> newWord;
    do {
      newWord = (_dictionary..shuffle()).first;
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
    if (userInput == _currentWordData["kanji"] ||
        userInput == _currentWordData["hiragana"] ||
        userInput == _currentWordData["katakana"]) {
      setState(() {
        _feedbackMessage = '正解です! (Correct!)';
        _showNextWordButton = true; // Show button to pick another word
      });
    } else {
      setState(() {
        _feedbackMessage = '不正解です。もう一度試してください。 (Incorrect. Try again.)';
        _showNextWordButton = false; // Hide button if the answer is incorrect
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Practice Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // "Guess the Word" title
              const Text(
                "単語を当ててください (Guess the Word):",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  hintText: "単語を入力してください... (Enter the word...)",
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
                child: const Text("答えを確認する (Check Answer)"),
              ),
              const SizedBox(height: 20),

              // Feedback message for the user
              Text(
                _feedbackMessage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _feedbackMessage == '正解です! (Correct!)' ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

              // Show the "Next Word" button only if the answer is correct
              if (_showNextWordButton)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: _pickRandomWord,
                    child: const Text("次の単語へ (Next Word)"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
