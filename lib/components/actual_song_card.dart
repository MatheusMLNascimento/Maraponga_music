import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/player_provider.dart';
import '../actual_song_page.dart';

// Card fixo que mostra a música/playlist atualmente tocando
class ActualSongCard extends StatelessWidget {
  const ActualSongCard({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);
    final playlist = player.playlist;
    final currentTrack = player.currentTrack;
    if (playlist == null || currentTrack == null) return const SizedBox.shrink();

    // Mostra até 2 artistas, depois "..."
    String artistText = '';
    final artists = currentTrack.artist.split(' e ');
    if (artists.length > 2) {
      artistText = '${artists[0]}, ${artists[1]}, ...';
    } else {
      artistText = currentTrack.artist;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ActualSongPage()),
        );
      },
      child: Card(
        color: Colors.black87,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Image.asset(
                currentTrack.image,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTrack.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      artistText,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Slider(
                      value: player.progress,
                      onChanged: player.setProgress,
                      activeColor: Colors.deepOrange,
                      inactiveColor: Colors.white24,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  player.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.deepOrange,
                ),
                onPressed: player.toggleFavorite,
              ),
              IconButton(
                icon: Icon(
                  player.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: player.togglePlayPause,
              ),
            ],
          ),
        ),
      ),
    );
  }
}