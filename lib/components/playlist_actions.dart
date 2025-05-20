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
    Key? key,
    required this.playlist,
    required this.onDelete,
    required this.onAddSong,
  }) : super(key: key);

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
              label: const Text('Adicionar à fila'),
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
              icon: const Icon(Icons.add),
              label: const Text('Adicionar música'),
              onPressed: onAddSong,
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
