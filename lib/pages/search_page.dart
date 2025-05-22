// ignore_for_file: deprecated_member_use

import 'package:app/components/playlist_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/custom_bottom_navigation_bar.dart';
// Para o modelo Playlist
import '../../../service/player_provider.dart';
import '../../../service/local_database.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Song> searchResults = [];

  @override
  void initState() {
    super.initState();
    LocalDatabase().init();
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

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Barra de busca estilizada e centralizada verticalmente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                  ),
                  onChanged: _search,
                ),
              ),
            ),
            Expanded(
              child: searchResults.isEmpty && _controller.text.isNotEmpty
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
                              trailing: IconButton(
                                icon: Icon(
                                  playerProvider.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.deepOrange,
                                ),
                                onPressed: () async {
                                  await LocalDatabase().addSongToFavorites(song);
                                  setState(() {});
                                },
                              ),
                              onTap: () {
                                // Toca a música selecionada no player global
                                playerProvider.setPlaylist(
                                  Playlist(
                                    title: song.title,
                                    artist: song.artist,
                                    items: 1,
                                    duration: song.duration,
                                    image: song.image, tracks: [],
                                  ),
                                );
                              },
                            );
                          },
                        ),
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
          if (index != 1) {
            Navigator.of(context).pop();
          }
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
