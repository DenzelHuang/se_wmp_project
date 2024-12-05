import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:se_wmp_project/widgets/app_drawer.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  File? _selectedImage;
  String _extractedText = ''; // State variable for extracted text
  final ImagePicker _picker = ImagePicker();

  // Method to capture an image using the camera
  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Method to select an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Method to process the selected image and extract text
  Future<void> _processImage() async {
    if (_selectedImage != null) {
      final inputImage = InputImage.fromFilePath(_selectedImage!.path);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text; // Update extracted text
      });

      // Display a snackbar to notify the user that text extraction is complete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Text extraction complete!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select or capture an image first.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner Page")),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        // Wrap the column with SingleChildScrollView
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display the selected image
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 250,
                  fit: BoxFit.cover,
                )
              else
                const Icon(
                  Icons.image,
                  size: 150,
                  color: Colors.grey,
                ),
              const SizedBox(height: 20),

              // Button to capture image
              ElevatedButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Take a Photo"),
              ),
              const SizedBox(height: 10),

              // Button to pick image from gallery
              ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text("Select from Gallery"),
              ),
              const SizedBox(height: 30),

              // Button to process image
              ElevatedButton.icon(
                onPressed: _processImage,
                icon: const Icon(Icons.check_circle),
                label: const Text("Scan"),
              ),
              const SizedBox(height: 20),

              // Display the extracted text
              if (_extractedText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _extractedText,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
