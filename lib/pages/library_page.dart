// ignore_for_file: use_build_context_synchronously

import 'package:app/service/player_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../service/local_database.dart';
import '../../components/playlist_card.dart';
import '../../components/bottom_nav_bar.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _selectedIndex = 2;

  // Exibe o diálogo para criar uma nova playlist (nome/descrição, depois música)
  Future<void> _showCreatePlaylistDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    // Primeiro pop-up: nome e descrição
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('Nova Playlist', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: descController,
                  maxLength: 100,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Avançar', style: TextStyle(color: Colors.deepOrange)),
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                Navigator.pop(context, {
                  'title': titleController.text.trim(),
                  'desc': descController.text.trim(),
                });
              },
            ),
          ],
        );
      },
    );

    if (result == null) return;

    // Agora navega para a SearchPage para selecionar músicas
    final Song? selectedSong = await Navigator.of(context).push<Song>(
      MaterialPageRoute(
        builder: (_) => _SearchPageForPlaylistCreation(),
      ),
    );

    if (selectedSong != null) {
      // Imagem padrão: da música selecionada
      final image = selectedSong.image;
      // Cria playlist e adiciona a música selecionada
      final playlist = await LocalDatabase().createPlaylist(
        result['title']!,
        result['desc']!,
        image,
      );
      // Corrigido: adiciona música à playlist criada e salva imediatamente
      await LocalDatabase().addSongToPlaylist(playlist.id, selectedSong);
      setState(() {});
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
    final playlists = LocalDatabase().getAllPlaylists();
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Suas Playlists'),
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
          body: playlists.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma playlist encontrada.',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlistData = playlists[index];
                    return PlaylistCard(
                      playlist: Playlist(
                        title: playlistData.title,
                        artist: playlistData.artist,
                        items: playlistData.items,
                        duration: playlistData.duration,
                        image: playlistData.image,
                        tracks: playlistData.songs,
                      ),
                      selected: false,
                      // Corrigido: navega para detalhes e toca a playlist
                      onTap: () {
                        final player = Provider.of<PlayerProvider>(context, listen: false);
                        if (playlistData.songs.isNotEmpty) {
                          player.setQueue(List<Song>.from(playlistData.songs));
                          player.setCurrentTrack(playlistData.songs.first);
                        }
                        Navigator.of(context).pushNamed(
                          '/playlist_details',
                          arguments: playlistData,
                        );
                      },
                      size: size,
                    );
                  },
                ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _selectedIndex,
            onTap: _onNavTapped,
          ),
        ),
        // Botão flutuante acima do ActualSongCard
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            onPressed: _showCreatePlaylistDialog,
            tooltip: 'Criar nova playlist',
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

// Página de busca para selecionar uma música para a nova playlist
class _SearchPageForPlaylistCreation extends StatefulWidget {
  @override
  State<_SearchPageForPlaylistCreation> createState() => _SearchPageForPlaylistCreationState();
}

class _SearchPageForPlaylistCreationState extends State<_SearchPageForPlaylistCreation> {
  final TextEditingController _controller = TextEditingController();
  List<Song> searchResults = [];

  @override
  void initState() {
    super.initState();
  }

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
