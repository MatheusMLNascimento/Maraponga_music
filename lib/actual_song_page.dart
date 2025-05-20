import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service/player_provider.dart';

// Modularizado: página de detalhes da música atual
class ActualSongPage extends StatelessWidget {
  const ActualSongPage({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);
    final currentTrack = player.currentTrack;
    if (currentTrack == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text('Nenhuma música tocando', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    String artistText = '';
    final artists = currentTrack.artist.split(' e ');
    if (artists.length > 2) {
      artistText = '${artists[0]}, ${artists[1]}, ...';
    } else {
      artistText = currentTrack.artist;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text('Tocando agora', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                currentTrack.image,
                width: 260,
                height: 260,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            currentTrack.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            artistText,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Text(
                  _formatDuration(player.progress, currentTrack.duration),
                  style: const TextStyle(color: Colors.white70),
                ),
                Expanded(
                  child: Slider(
                    value: player.progress,
                    onChanged: player.setProgress,
                    activeColor: Colors.deepOrange,
                    inactiveColor: Colors.white24,
                  ),
                ),
                Text(
                  currentTrack.duration,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shuffle, color: Colors.white, size: 32),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                onPressed: () {},
              ),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: IconButton(
                  icon: Icon(
                    player.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                    size: 40,
                  ),
                  onPressed: player.togglePlayPause,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.repeat, color: Colors.white, size: 32),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(Icons.thumb_up_alt_outlined, color: Colors.white70),
                  const SizedBox(height: 4),
                  Text('146 mil', style: TextStyle(color: Colors.white70)),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.comment_outlined, color: Colors.white70),
                  const SizedBox(height: 4),
                  Text('323', style: TextStyle(color: Colors.white70)),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.playlist_add, color: Colors.white70),
                  const SizedBox(height: 4),
                  Text('Salvar', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Tabs para "A SEGUIR", "LETRA", "RELACIONADOS"
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: Colors.deepOrange,
                  tabs: const [
                    Tab(text: 'A SEGUIR'),
                    Tab(text: 'LETRA'),
                    Tab(text: 'RELACIONADOS'),
                  ],
                ),
                SizedBox(
                  height: 120,
                  child: TabBarView(
                    children: [
                      // A SEGUIR
                      Center(child: Text('Fila de músicas', style: TextStyle(color: Colors.white54))),
                      // LETRA
                      Center(child: Text('Letra da música', style: TextStyle(color: Colors.white54))),
                      // RELACIONADOS
                      Center(child: Text('Músicas relacionadas', style: TextStyle(color: Colors.white54))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double progress, String duration) {
    // duration: "mm:ss"
    final parts = duration.split(':');
    final totalSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final currentSeconds = (progress * totalSeconds).toInt();
    final min = currentSeconds ~/ 60;
    final sec = currentSeconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}
