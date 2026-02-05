import 'dart:io';
import 'package:flutter/material.dart';

class PictureScreen extends StatelessWidget {
  final String? imagePath;
  const PictureScreen({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return const Center(child: Text('No picture taken'));
    }

    return Center(
      child: Image.file(File(imagePath!)),
    );
  }
}
