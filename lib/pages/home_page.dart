import 'package:flutter/material.dart';
import '../../components/playlist_card.dart';
import '../../components/custom_app_bar.dart';
import '../../components/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../service/player_provider.dart';
import '../../service/local_database.dart';
import '../components/actual_song_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String? selectedGenre;
  List<PlaylistData> _playlists = [];
  int _lastSelectedPlaylistIndex = -1;

  @override
  void initState() {
    super.initState();
    LocalDatabase().init().then((_) {
      setState(() {
        _playlists = List<PlaylistData>.from(LocalDatabase().getTop5Playlists());
      });
    });
  }

  // Move a playlist para o topo, toca e destaca
  void _onPlaylistTap(int index) {
    final player = Provider.of<PlayerProvider>(context, listen: false);
    if (_playlists[index].songs.isNotEmpty) {
      player.setQueue(List<Song>.from(_playlists[index].songs));
      player.setCurrentTrack(_playlists[index].songs.first);
    }
    setState(() {
      _lastSelectedPlaylistIndex = index;
    });
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
    final size = MediaQuery.of(context).size;
    final genres = LocalDatabase().getAllGenres();
    Provider.of<PlayerProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(size: size),
      body: Column(
        children: <Widget>[
          _buildGenreChips(genres, size),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final playlistData = _playlists[index];
                  // Destaca apenas a playlist selecionada por último
                  final isSelected = index == _lastSelectedPlaylistIndex;
                  return PlaylistCard(
                    playlist: Playlist(
                      title: playlistData.title,
                      artist: playlistData.artist,
                      items: playlistData.items,
                      duration: playlistData.duration,
                      image: playlistData.image,
                      tracks: playlistData.songs,
                    ),
                    selected: isSelected,
                    onTap: () => _onPlaylistTap(index),
                    size: size,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ActualSongCard(),
          BottomNavBar(
            currentIndex: _selectedIndex,
            onTap: _onNavTapped,
          ),
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
                  selectedColor: Colors.deepOrange.withAlpha(
                    (0.5 * 255).toInt(),
                  ),
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
