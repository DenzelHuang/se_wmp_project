import 'dart:io';
import 'package:flutter/material.dart';

class ScannerProvider with ChangeNotifier {
  File? _selectedImage;
  String _ocrText = '';
  String _translatedText = '';
  String _translatedSource = '';

  // Getters
  File? get selectedImage => _selectedImage;
  String get ocrText => _ocrText;
  String get translatedText => _translatedText;
  String get translatedSource => _translatedSource;

  // Setters
  void setImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  void setOcrText(String text) {
    _ocrText = text;
    notifyListeners();
  }

  void setTranslatedText(String text) {
    _translatedText = text;
    notifyListeners();
  }

  void setTranslatedSource(String text) {
    _translatedSource= text;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _selectedImage = null;
    _ocrText = '';
    _translatedText = '';
    notifyListeners();
  }
}
