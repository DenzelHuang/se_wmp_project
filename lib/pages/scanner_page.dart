import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:se_wmp_project/widgets/fullscreen_image.dart';
import 'package:translator/translator.dart';
import 'package:provider/provider.dart';
import 'package:se_wmp_project/widgets/app_drawer.dart';
import 'package:se_wmp_project/providers/scanner_provider.dart';
import 'package:se_wmp_project/providers/language_provider.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final ImagePicker _picker = ImagePicker();
  final translator = GoogleTranslator();
  final FlutterTts _flutterTts = FlutterTts();
  String _translationSource = "";

  // Method to capture an image using the camera
  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Provider.of<ScannerProvider>(context, listen: false)
          .setImage(File(image.path));
    }
  }

  // Method to select an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Provider.of<ScannerProvider>(context, listen: false)
          .setImage(File(image.path));
    }
  }

  // Method to process the selected image and extract text
  Future<void> _processImage() async {
    final scannerProvider =
        Provider.of<ScannerProvider>(context, listen: false);
    if (scannerProvider.selectedImage != null) {
      final inputImage =
          InputImage.fromFilePath(scannerProvider.selectedImage!.path);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      scannerProvider.setOcrText(recognizedText.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Text extraction complete!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select or capture an image first.")),
      );
    }
  }

  // Method to translate text to English
  Future<void> _translateText() async {
    final scannerProvider =
        Provider.of<ScannerProvider>(context, listen: false);
    final selectedLanguage =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    
    // Set the translation source in the provider
    scannerProvider.setTranslatedSource(selectedLanguage);

    if (scannerProvider.ocrText.isNotEmpty) {
      try {
        final translation = await translator.translate(
          scannerProvider.ocrText,
          from: _getLanguageCode(selectedLanguage),
          to: 'en',
        );

        scannerProvider.setTranslatedText(translation.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Translation complete!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to translate text.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No text to translate.")),
      );
    }
  }

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

  // Text-to-Speech Functionality
  Future<void> _speak(String text, String language) async {
    if (text.isNotEmpty) {
      await _flutterTts.setLanguage(language); // Dynamically set language
      await _flutterTts.setSpeechRate(0.5); // Set speech rate
      await _flutterTts.setVolume(1.0); // Set volume
      await _flutterTts.speak(text); // Speak the text
    }
  }

  @override
  void dispose() {
    _flutterTts.stop(); // Stop any ongoing speech when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scannerProvider = Provider.of<ScannerProvider>(context);

    // Update the local variable with the value from the provider
    _translationSource = scannerProvider.translatedSource;
    
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner Page")),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Display selected image
                if (scannerProvider.selectedImage != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullscreenImageView(
                            imageFile: scannerProvider.selectedImage!,
                          ),
                        ),
                      );
                    },
                    child: Image.file(
                      scannerProvider.selectedImage!,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Icon(Icons.image, size: 150, color: Colors.grey),

                const SizedBox(height: 20),

                // Buttons to capture/select images
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _captureImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Take a Photo"),
                      ),
                    ),
                    const SizedBox(width: 10), // Add spacing between the buttons
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Gallery"),
                      ),
                    ),
                  ],
                ),

                // Button to process image
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child:
                      ElevatedButton.icon(
                        onPressed: _processImage,
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Scan"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // OCR Output
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),  // Border color and width
                    borderRadius: BorderRadius.circular(8),  // Optional: to make rounded corners
                  ),
                  child: TextField(
                    controller: TextEditingController(
                      text: scannerProvider.ocrText,
                    ), // Pre-fill with OCR text
                    maxLines: 10,
                    decoration: const InputDecoration(
                      border: InputBorder.none, // Remove default border of the TextField
                      hintText: "Extracted text will appear here...",
                    ),
                    onChanged: (value) {
                      scannerProvider.setOcrText(value);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons for translation and dictionary
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Translate button
                    Expanded(child: 
                      ElevatedButton(
                        onPressed: _translateText,
                        child: const Text("Translate to English"),
                      )
                    ),
                    const SizedBox(width: 10), // Add spacing between the buttons

                    // Add to Dictionary button
                    Expanded(child: 
                      ElevatedButton(
                        onPressed: () {}, // Placeholder function
                        child: const Text("Add to Dictionary"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // TTS Buttons for OCR and Translation
                if (scannerProvider.ocrText.isNotEmpty || scannerProvider.translatedText.isNotEmpty)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (scannerProvider.ocrText.isNotEmpty)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final selectedLanguage =
                                      Provider.of<LanguageProvider>(context, listen: false)
                                          .selectedLanguage;
                                  _speak(
                                    scannerProvider.ocrText,
                                    _getLanguageCode(selectedLanguage), // Pass the selected language
                                  );
                                },
                                icon: const Icon(Icons.volume_up),
                                label: const Text("Read OCR"),
                              ),
                            ),
                          if (scannerProvider.ocrText.isNotEmpty &&
                              scannerProvider.translatedText.isNotEmpty)
                            const SizedBox(width: 10),
                          if (scannerProvider.translatedText.isNotEmpty)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _speak(scannerProvider.translatedText, "en-US"); // Always read translations in English
                                },
                                icon: const Icon(Icons.volume_up),
                                label: const Text("Read Translation"),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10), // Add spacing between the rows
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _flutterTts.stop(),
                              icon: const Icon(Icons.stop),
                              label: const Text("Stop Reading"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 10),

                // Display the translation source
                if (_translationSource.isNotEmpty)
                  Text(
                    "Translated from ${scannerProvider.translatedSource}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10),

                // Translation output
                if (scannerProvider.translatedText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: MediaQuery.of(context).size.width - 32, // Same width as OCR container
                    child: Text(
                      scannerProvider.translatedText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
