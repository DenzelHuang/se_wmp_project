import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:se_wmp_project/providers/language_provider.dart';

class WordDetailPage extends StatelessWidget {
  final String word;
  final String meaning;

  final FlutterTts _flutterTts = FlutterTts();

  WordDetailPage({
    super.key,
    required this.word,
    required this.meaning,
  });

  // Helper to get language code
  String _getLanguageCode(String language) {
    switch (language.toLowerCase()) {
      case 'french':
        return 'fr';
      case 'japanese':
        return 'ja';
      default:
        return 'auto';
    }
  }

  // Method to handle TTS for the word
  Future<void> _speakWord(String word, String language) async {
    if (word.isNotEmpty) {
      await _flutterTts.setLanguage(language); // Set to currently selected language
      await _flutterTts.setSpeechRate(0.5); // Set speech rate
      await _flutterTts.setVolume(1.0); // Set volume
      await _flutterTts.speak(word); // Speak the word
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Word Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Word:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    word,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final selectedLanguage =
                      Provider.of<LanguageProvider>(context, listen: false)
                          .selectedLanguage;
                    _speakWord(
                      word,
                      _getLanguageCode(selectedLanguage)
                    );
                  }, // Call TTS when button is pressed
                  icon: const Icon(Icons.volume_up),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Meaning:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              meaning,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
