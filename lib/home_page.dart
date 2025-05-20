import 'dart:async';
import 'package:flutter/material.dart';
import 'search_page.dart';
import '../components/playlist_card.dart';
import '../components/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../service/player_provider.dart';
import '../service/local_database.dart';
import 'library_page.dart'; // Adicione este import para a página de biblioteca

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedPlaylist = 0;
  String selectedGenre = 'Romance';

  @override
  void initState() {
    super.initState();
    LocalDatabase().init().then((_) {
      setState(() {});
    });
  }

  // Navega entre as abas do app
  void _onNavTapped(int index) {
    if (index == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchPage()));
    } else if (index == 2) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LibraryPage()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Seleciona uma playlist e atualiza o player global
  void _onPlaylistTap(int index, List<PlaylistData> playlists) async {
    final player = Provider.of<PlayerProvider>(context, listen: false);
    final playlistData = playlists[index];
    // Converte PlaylistData para Playlist
    final playlist = Playlist(
      title: playlistData.title,
      artist: playlistData.artist,
      items: playlistData.items,
      duration: playlistData.duration,
      image: playlistData.image, tracks: [],
    );
    player.setPlaylist(playlist);
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      _selectedPlaylist = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final genres = LocalDatabase().getAllGenres();
    final playlists = LocalDatabase().getTop5Playlists();

    return Scaffold(
      appBar: CustomAppBar(size: size),
      body: Column(
        children: <Widget>[
          _buildGenreChips(genres, size),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlistData = playlists[index];
                  final playlist = Playlist(
                    title: playlistData.title,
                    artist: playlistData.artist,
                    items: playlistData.items,
                    duration: playlistData.duration,
                    image: playlistData.image, tracks: [],
                  );
                  return PlaylistCard(
                    playlist: playlist,
                    selected: _selectedPlaylist == index,
                    onTap: () async {
                      await LocalDatabase().updatePlaylistAccess(playlistData.id);
                      _onPlaylistTap(index, playlists);
                    },
                    size: size,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Busca'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }

  // Constrói os chips de seleção de gênero
  Widget _buildGenreChips(List<String> genres, Size size) {
    final double fontSizeSubtitle = size.width * 0.035;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.015,
        horizontal: size.width * 0.02,
      ),
      // Corrigido: Use SingleChildScrollView horizontal para evitar overflow
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...genres.map((genre) {
              final isSelected = selectedGenre == genre;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    genre,
                    style: TextStyle(fontSize: fontSizeSubtitle),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.deepOrange.withAlpha((0.5 * 255).toInt()),
                  onSelected: (_) {
                    setState(() => selectedGenre = genre);
                  },
                  backgroundColor: const Color(0xFF232323),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            Icon(
              Icons.more_horiz,
              color: Colors.white,
              size: size.width * 0.05,
            ),
          ],
        ),
      ),
    );
  }
}
