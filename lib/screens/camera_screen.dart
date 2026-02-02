import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

late List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  final Function(String) onPictureTaken;
  const CameraScreen({super.key, required this.onPictureTaken});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool flashOn = false;
  int cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[cameraIndex], ResolutionPreset.medium);
    await controller.initialize();
    setState(() {});
  }

  Future<void> takePicture() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    final image = await controller.takePicture();
    await image.saveTo(filePath);

    widget.onPictureTaken(filePath);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Photo Taken'),
        content: Text('Photo saved at:\n$filePath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void switchCamera() async {
    cameraIndex = cameraIndex == 0 ? 1 : 0;
    await controller.dispose();
    initCamera();
  }

  void toggleFlash() async {
    flashOn = !flashOn;
    await controller.setFlashMode(
        flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
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
                  onPressed: switchCamera),
              IconButton(
                  icon: Icon(
                      flashOn ? Icons.flash_on : Icons.flash_off),
                  onPressed: toggleFlash),
            ],
          ),
        ),
        Expanded(child: CameraPreview(controller)),
        Padding(
          padding: const EdgeInsets.all(20),
          child: FloatingActionButton(
            onPressed: takePicture,
            child: const Icon(Icons.camera),
          ),
        )
      ],
    );
  }
}
