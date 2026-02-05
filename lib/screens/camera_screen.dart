import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraScreen extends StatefulWidget {
  final Function(String) onPictureTaken;
  const CameraScreen({super.key, required this.onPictureTaken});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool flashOn = false;
  int cameraIndex = 0;
  bool isInitializing = true;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      controller = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.medium,
      );
      await controller!.initialize();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    } finally {
      setState(() {
        isInitializing = false;
      });
    }
  }

  Future<void> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory photosDir =
        Directory(path.join(appDir.path, 'photos'));

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final String fileName =
        'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = path.join(photosDir.path, fileName);

    final XFile image = await controller!.takePicture();
    await image.saveTo(filePath);

    widget.onPictureTaken(filePath);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Photo Taken'),
        content: Text('Saved at:\n$filePath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void switchCamera() async {
    if (controller == null) return;

    cameraIndex = cameraIndex == 0 ? 1 : 0;
    await controller!.dispose();
    setState(() => isInitializing = true);
    initCamera();
  }

  void toggleFlash() async {
    if (controller == null) return;

    flashOn = !flashOn;
    await controller!.setFlashMode(
      flashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing || controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          color: Colors.pink.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.cameraswitch),
                onPressed: switchCamera,
              ),
              IconButton(
                icon: Icon(
                  flashOn ? Icons.flash_on : Icons.flash_off,
                ),
                onPressed: toggleFlash,
              ),
            ],
          ),
        ),
        Expanded(child: CameraPreview(controller!)),
        Padding(
          padding: const EdgeInsets.all(20),
          child: FloatingActionButton(
            onPressed: takePicture,
            child: const Icon(Icons.camera),
          ),
        ),
      ],
    );
  }
}
