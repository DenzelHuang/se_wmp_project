import 'package:flutter/material.dart';
import 'dart:io';

class FullscreenImageView extends StatelessWidget {
  final File imageFile;

  const FullscreenImageView({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Allow panning
          minScale: 1.0, // Minimum zoom scale
          maxScale: 5.0, // Maximum zoom scale
          clipBehavior: Clip.none, // Allow the image to overflow the initial bounds
          child: AspectRatio(
            aspectRatio: MediaQuery.of(context).size.aspectRatio,
            child: Image.file(
              imageFile,
              fit: BoxFit.contain, // Fits the image within the bounds of the screen initially
            ),
          ),
        ),
      ),
    );
  }
}
