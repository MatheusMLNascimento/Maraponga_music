import 'package:app/components/actual_song_card.dart';
import 'package:app/components/music_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/local_database.dart';
import '../service/player_provider.dart';
import '../components/playlist_actions.dart';
import '../components/playlist_details_header.dart';
import '../components/bottom_nav_bar.dart';
import '../pages/playlist_search_page.dart';

// Modularizado: Widget para playlist details page
class PlaylistDetailsPage extends StatefulWidget {
  final PlaylistData playlist;
  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  late PlaylistData playlist;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    playlist = widget.playlist;
  }

  // Mostra diálogo de confirmação para apagar playlist
  Future<void> _deletePlaylist() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: const Text(
              'Apagar Playlist',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Tem certeza que deseja apagar esta playlist? Esta ação é permanente.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white70),
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  'Apagar',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await LocalDatabase().removePlaylist(playlist.id);
      if (mounted) Navigator.pop(context);
    }
  }

  // Adiciona música à playlist e atualiza a tela imediatamente
  Future<void> _addSongToPlaylist() async {
    final Song? selectedSong = await Navigator.of(context).push<Song>(
      MaterialPageRoute(
        builder: (_) => SearchPageForPlaylistAdd(playlist: playlist),
      ),
    );
    if (selectedSong != null) {
      await LocalDatabase().addSongToPlaylist(playlist.id, selectedSong);
      // Atualiza a instância da playlist para refletir a música adicionada
      final updated = LocalDatabase().getAllPlaylists().firstWhere(
        (p) => p.id == playlist.id,
      );
      setState(() {
        playlist = updated;
      });
    }
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/search');
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/library');
    } else if (index == 3) {
      // Implemente a navegação para Config se necessário
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text(
          playlist.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.deepOrange),
            tooltip: 'Reproduzir playlist',
            onPressed: () {
              player.setQueue(List.from(playlist.songs));
              if (playlist.songs.isNotEmpty) {
                player.setCurrentTrack(playlist.songs.first);
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              PlaylistDetailsHeader(playlist: playlist),
              PlaylistActions(
                playlist: playlist,
                onDelete: _deletePlaylist,
                onAddSong: _addSongToPlaylist,
              ),
              const Divider(color: Colors.white24, thickness: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: playlist.songs.length,
                  itemBuilder: (context, index) {
                    final song = playlist.songs[index];
                    return MusicCard(
                      song: song,
                      onPlay: () {
                        player.setQueue(List.from(playlist.songs));
                        player.setCurrentTrack(song);
                      },
                      showRemoveFromPlaylist: true,
                      playlistId: playlist.id,
                    );
                  },
                ),
              ),
            ],
          ),
          // Botão flutuante para adicionar música, acima do actualsongcard
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              onPressed: _addSongToPlaylist,
              tooltip: 'Adicionar música',
              child: const Icon(Icons.add),
            ),
          ),
          const Positioned(
          bottom: -20,
          left: 0,
          right: 0,
          child: ActualSongCard(),
        ),
        ],
      ),
    );
  }
}
