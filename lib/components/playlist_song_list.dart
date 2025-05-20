import 'package:app/components/playlist_card.dart';
import 'package:app/service/local_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/player_provider.dart';

class PlaylistSongList extends StatelessWidget {
  final PlaylistData playlist;
  const PlaylistSongList({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context, listen: false);
    final songs = playlist.songs;
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: Image.asset(
            song.image,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
          title: Text(
            song.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${song.artist} • ${song.duration}',
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () {
            player.setPlaylist(
              Playlist(
                title: playlist.title,
                artist: playlist.artist,
                items: playlist.items,
                duration: playlist.duration,
                image: playlist.image, tracks: [],
              ),
            );
          },
        );
      },
    );
  }
}
