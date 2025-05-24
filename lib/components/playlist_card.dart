import 'package:app/service/local_database.dart';
import 'package:app/service/player_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importa a página de detalhes da playlist
import '../pages/playlist_details_page.dart';

// Modelo de dados para playlist
class Playlist {
  final String title;
  final String artist;
  final int items;
  final String duration;
  final String image;

  Playlist({
    required this.title,
    required this.artist,
    required this.items,
    required this.duration,
    required this.image, required List<Song> tracks,
  });
}

// Card visual para exibir uma playlist na lista
class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final bool selected;
  final VoidCallback onTap;
  final Size size;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.selected,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? Colors.deepOrange.withAlpha(128) : Colors.grey[900],
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6), // Cantos arredondados
          child: Image.asset(
            playlist.image,
            width: size.width * 0.15,
            height: size.width * 0.15,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.music_note,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          playlist.title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${playlist.items} músicas • ${playlist.duration}',
          style: const TextStyle(color: Colors.white70),
        ),
        onTap: () async {
          // Busca a playlist real do banco local pelo título (ou outro identificador)
          final db = LocalDatabase();
          final playlists = db.getAllPlaylists();
          PlaylistData? realPlaylist;
          try {
            realPlaylist = playlists.firstWhere(
              (p) => p.title == playlist.title,
            );
          } catch (e) {
            realPlaylist = await db.createPlaylist(
              playlist.title,
              playlist.artist,
              playlist.image,
            );
          }
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlaylistDetailsPage(playlist: realPlaylist!),
            ),
          );
        },
        // Botão de play para tocar a playlist
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.deepOrange),
          tooltip: 'Reproduzir playlist',
          onPressed: () async {
            final db = LocalDatabase();
            final playlists = db.getAllPlaylists();
            PlaylistData? realPlaylist;
            try {
              realPlaylist = playlists.firstWhere(
                (p) => p.title == playlist.title,
              );
            } catch (e) {
              realPlaylist = await db.createPlaylist(
                playlist.title,
                playlist.artist,
                playlist.image,
              );
            }
            if (realPlaylist.songs.isNotEmpty) {
              // ignore: use_build_context_synchronously
              final player = Provider.of<PlayerProvider>(context, listen: false);
              player.setQueue(List.from(realPlaylist.songs));
              player.setCurrentTrack(realPlaylist.songs.first);
            }
          },
        ),
      ),
    );
  }
}