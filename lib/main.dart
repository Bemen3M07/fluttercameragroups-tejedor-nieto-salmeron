import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';
import 'screens/picture_screen.dart';
import 'screens/music_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String? lastImagePath;

  @override
  Widget build(BuildContext context) {
    final screens = [
      CameraScreen(
        onPictureTaken: (path) {
          setState(() => lastImagePath = path);
        },
      ),
      PictureScreen(imagePath: lastImagePath),
      const MusicScreen(),
    ];

    final titles = ['Càmera', 'Picture', 'Music Player'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex]),
        centerTitle: true,
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Càmera'),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Picture'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Music'),
        ],
      ),
    );
  }
}
