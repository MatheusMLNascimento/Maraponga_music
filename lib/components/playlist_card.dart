import 'package:app/service/local_database.dart';
import 'package:flutter/material.dart';
// Importa a página de detalhes da playlist
import '../playlist_details_page.dart';

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
        leading: Image.asset(
          playlist.image,
          width: size.width * 0.15,
          height: size.width * 0.15,
          fit: BoxFit.cover,
        ),
        title: Text(
          playlist.title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${playlist.items} músicas • ${playlist.duration}',
          style: const TextStyle(color: Colors.white70),
        ),
        onTap: onTap,
        // Botão de 3 pontinhos para acessar detalhes da playlist
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          onPressed: () async {
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
        ),
      ),
    );
  }
}