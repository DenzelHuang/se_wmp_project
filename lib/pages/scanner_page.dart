import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:se_wmp_project/widgets/app_drawer.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  File? _selectedImage;
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

  // Method to proceed after image selection
  void _proceedWithImage() {
    if (_selectedImage != null) {
      // TODO: Handle proceeding with the selected image
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image confirmed!")),
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
      body: Center(
        // Center the entire content both horizontally and vertically
        child: Column(
          mainAxisSize: MainAxisSize.min, // To prevent taking up full height
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

            // Button to proceed/confirm
            ElevatedButton.icon(
              onPressed: _proceedWithImage,
              icon: const Icon(Icons.check_circle),
              label: const Text("Scan"),
            ),
          ],
        ),
      ),
    );
  }
}
