import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = "French"; // Default language is French

  String get selectedLanguage => _selectedLanguage;

  // Constructor: Load the saved language from a file when the provider is created
  LanguageProvider() {
    _loadLanguageFromFile();
  }

  // Change the selected language and save it to a file
  void changeLanguage(String newLanguage) async {
    _selectedLanguage = newLanguage;
    notifyListeners(); // Notify widgets that the language has changed
    await _saveLanguageToFile(); // Save the new language to the file
  }

  // Save the selected language to a file
  Future<void> _saveLanguageToFile() async {
    try {
      final file = await _getLanguageFile();
      await file.writeAsString(_selectedLanguage); // Write the language to the file
    } catch (e) {
      debugPrint("Error saving language: $e"); // Log any errors
    }
  }

  // Load the selected language from a file
  Future<void> _loadLanguageFromFile() async {
    try {
      final file = await _getLanguageFile();
      if (await file.exists()) {
        final savedLanguage = await file.readAsString(); // Read the language from the file
        _selectedLanguage = savedLanguage;
        notifyListeners(); // Notify widgets of the loaded language
      }
    } catch (e) {
      debugPrint("Error loading language: $e"); // Log any errors
    }
  }

  // Get the file where the language setting is stored
  Future<File> _getLanguageFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/language.txt'); // Return the file path
  }
}
