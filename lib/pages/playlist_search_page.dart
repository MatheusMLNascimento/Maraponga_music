// Modularizado: página de busca para adicionar música à playlist
import 'package:app/service/local_database.dart';
import 'package:flutter/material.dart';

class SearchPageForPlaylistAdd extends StatefulWidget {
  final PlaylistData playlist;
  const SearchPageForPlaylistAdd({super.key, required this.playlist});

  @override
  State<SearchPageForPlaylistAdd> createState() => SearchPageForPlaylistAddState();
}

class SearchPageForPlaylistAddState extends State<SearchPageForPlaylistAdd> {
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
