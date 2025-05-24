// ignore_for_file: deprecated_member_use
import 'package:app/components/actual_song_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/custom_bottom_navigation_bar.dart';
import '../../../components/music_card.dart';
// Para o modelo Playlist
import '../service/player_provider.dart';
import '../../../service/local_database.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> searchResults = [];
  int _selectedIndex = 1;

  void _search(String query) async {
    // For demonstration, let's assume you have a list of all songs in LocalDatabase().getAllSongs()
    final allSongs = LocalDatabase().getAllSongs();
    setState(() {
      searchResults =
          allSongs
              .where(
                (song) =>
                    song.title.toLowerCase().contains(query.toLowerCase()) ||
                    song.artist.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Barra de busca estilizada e centralizada verticalmente
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF232323),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Digite o nome do artista ou música',
                    hintStyle: TextStyle(color: Colors.white54),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                  ),
                  onChanged: _search,
                ),
              ),
            ),
            Expanded(
              child:
                  searchResults.isEmpty && _controller.text.isNotEmpty
                      ? const Center(
                        child: Text(
                          'Nenhum resultado',
                          style: TextStyle(color: Colors.white54, fontSize: 18),
                        ),
                      )
                      : searchResults.isEmpty
                      ? const SizedBox.shrink()
                      : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final song = searchResults[index];
                          return MusicCard(
                            song: song,
                            onPlay: () {
                              final queue = List<Song>.from(player.queue);
                              final currentIndex = player.queueIndex;
                              queue.removeWhere((s) => s.id == song.id);
                              final insertIndex = currentIndex + 1;
                              queue.insert(
                                insertIndex > queue.length
                                    ? queue.length
                                    : insertIndex,
                                song,
                              );
                              player.setQueue(queue);
                              player.setCurrentTrack(song);
                            },
                            showRemoveFromPlaylist: false,
                          );
                        },
                      ),
            ),
            const Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: ActualSongCard(),
            ),
          ],
        ),
      ),
      // Barra de navegação inferior
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Fecha a página de busca se trocar de aba
          if (index == _selectedIndex) return;
          setState(() {
            _selectedIndex = index;
          });
          // Navegação entre as páginas principais
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case 1:
              // Já está na busca
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/library');
              break;
            case 3:
              Navigator.of(context).pushReplacementNamed('/settings');
              break;
          }
        },
      ),
    );
  }
}
