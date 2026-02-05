import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer player = AudioPlayer();

  // 🎶 Canciones en assets
final List<String> songs = [
  'audio/Beethoven-Virus.mp3',
  'audio/Himno-de-España.mp3',
  'audio/Nasa-Histoires-Bugambilia.mp3',
  'audio/Red-Sun-in-the-Sky.mp3',
];

  int? currentIndex;
  bool isPlaying = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });

    player.onPositionChanged.listen((p) {
      setState(() => position = p);
    });

    player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  Future<void> playSong(int index) async {
    await player.stop();
    await player.play(AssetSource(songs[index]));
    setState(() {
      currentIndex = index;
      isPlaying = true;
    });
  }

  Future<void> togglePlayPause() async {
    if (!isPlaying) {
      if (currentIndex != null) {
        await player.resume();
        setState(() => isPlaying = true);
      }
    } else {
      await player.pause();
      setState(() => isPlaying = false);
    }
  }

  String get songName =>
      currentIndex == null
          ? 'Selecciona una canción'
          : songs[currentIndex!].split('/').last;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🎵 Nombre de la canción actual
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            songName,
            style: const TextStyle(fontSize: 18),
          ),
        ),

        // ⏱ Barra de progreso
        Slider(
          min: 0,
          max: duration.inSeconds.toDouble(),
          value: position.inSeconds
              .toDouble()
              .clamp(0, duration.inSeconds.toDouble()),
          onChanged: (value) async {
            await player.seek(Duration(seconds: value.toInt()));
          },
        ),

        // ▶️ ⏸ Controles
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 60,
          ),
          onPressed: togglePlayPause,
        ),

        const Divider(),

        // 📃 LISTA DE CANCIONES
        Expanded(
          child: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final name = songs[index].split('/').last;
              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(name),
                selected: index == currentIndex,
                onTap: () => playSong(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
