import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service/local_database.dart';
import 'service/player_provider.dart';
import 'components/playlist_actions.dart';
import 'components/playlist_details_header.dart';

// Modularizado: Widget para playlist details page
class PlaylistDetailsPage extends StatefulWidget {
  final PlaylistData playlist;
  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  late PlaylistData playlist;

  @override
  void initState() {
    super.initState();
    playlist = widget.playlist;
  }

  // Mostra diálogo de confirmação para apagar playlist
  Future<void> _deletePlaylist() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Apagar Playlist', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tem certeza que deseja apagar esta playlist? Esta ação é permanente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
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
        builder: (_) => _SearchPageForPlaylistAdd(playlist: playlist),
      ),
    );
    if (selectedSong != null) {
      await LocalDatabase().addSongToPlaylist(playlist.id, selectedSong);
      // Atualiza a instância da playlist para refletir a música adicionada
      final updated = LocalDatabase().getAllPlaylists().firstWhere((p) => p.id == playlist.id);
      setState(() {
        playlist = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text(
          playlist.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      // Adiciona a navigationBar padrão do app
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          // Implemente a navegação conforme necessário
          if (index == 0) Navigator.of(context).pushReplacementNamed('/home');
          if (index == 1) Navigator.of(context).pushReplacementNamed('/search');
          if (index == 2) Navigator.of(context).pushReplacementNamed('/library');
          if (index == 3) Navigator.of(context).pushReplacementNamed('/settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Busca'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
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
                        // Envia apenas os dados da música para o actualsongcard e define a fila como as músicas da playlist
                        player.setQueue(List.from(playlist.songs));
                        player.setCurrentTrack(song);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Botão flutuante para adicionar música, acima do actualsongcard
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              onPressed: _addSongToPlaylist,
              tooltip: 'Adicionar música',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

// Modularizado: página de busca para adicionar música à playlist
class _SearchPageForPlaylistAdd extends StatefulWidget {
  final PlaylistData playlist;
  const _SearchPageForPlaylistAdd({required this.playlist});

  @override
  State<_SearchPageForPlaylistAdd> createState() => _SearchPageForPlaylistAddState();
}

class _SearchPageForPlaylistAddState extends State<_SearchPageForPlaylistAdd> {
  final TextEditingController _controller = TextEditingController();
  List<Song> searchResults = [];

  void _search(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        searchResults = [];
      } else {
        searchResults = LocalDatabase().searchSongs(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Digite o nome do artista ou música',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
      ),
      body: searchResults.isEmpty
          ? const Center(
              child: Text(
                'Nenhum resultado',
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final song = searchResults[index];
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
                    Navigator.pop(context, song);
                  },
                );
              },
            ),
    );
  }
}
