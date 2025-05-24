import 'package:app/service/local_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/player_provider.dart';

// Widget modularizado para ações de playlist (reproduzir, adicionar à fila, apagar)
class PlaylistActions extends StatelessWidget {
  final PlaylistData playlist;
  final VoidCallback onDelete;
  final VoidCallback onAddSong;

  const PlaylistActions({
    super.key,
    required this.playlist,
    required this.onDelete,
    required this.onAddSong,
  });

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Reproduzir'),
              onPressed: () {
                if (playlist.songs.isNotEmpty) {
                  player.setQueue(List.from(playlist.songs));
                  player.setCurrentTrack(playlist.songs.first);
                }
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.queue_music),
              label: const Text('Fila'),
              onPressed: () {
                player.addToQueue(playlist.songs);
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.shuffle),
              label: const Text('Aleatório'),
              onPressed: () {
                final player = Provider.of<PlayerProvider>(context, listen: false);
                final shuffled = List<Song>.from(playlist.songs)..shuffle();
                if (shuffled.isNotEmpty) {
                  player.setQueue(shuffled);
                  player.setCurrentTrack(shuffled.first);
                }
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.delete),
              label: const Text('Apagar'),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
