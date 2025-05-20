// ...existing imports...
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'search_page.dart';
import './components/components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedPlaylist = 0;
  String selectedGenre = 'Romance';
  double _progress = 0.0;
  bool _isPlaying = false;
  bool _isFavorite = false;
  Timer? _progressTimer;

  final List<Map<String, dynamic>> playlists = <Map<String, dynamic>>[
    {
      'title': 'Amianto',
      'artist': 'Supercombo e Chrono',
      'items': 21,
      'duration': '43:05',
      'image': 'assets/amianto.png',
    },
    {
      'title': 'Adeus, Aurora',
      'artist': 'Supercombo',
      'items': 32,
      'duration': '1:03:00',
      'image': 'assets/adeus_aurora.png',
    },
    {
      'title': 'Rogério',
      'artist': 'M4rkim e outros...',
      'items': 133,
      'duration': '10:43:05',
      'image': 'assets/rogerio.png',
    },
    {
      'title': 'Infame',
      'artist': 'Supercombo e outros...',
      'items': 9,
      'duration': '23:26',
      'image': 'assets/infame.png',
    },
    {
      'title': 'Mega mix',
      'artist': 'Supercombo e outros...',
      'items': 29,
      'duration': '52:19',
      'image': 'assets/mega_mix.png',
    },
  ];

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == 1) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SearchPage()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onPlaylistTap(int index) async {
    setState(() {
      _selectedPlaylist = index;
      _progress = 0.0;
      _isPlaying = false;
      _isFavorite = false;
    });
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (
        timer,
      ) {
        setState(() {
          _progress += 0.01;
          if (_progress >= 1.0) {
            _progress = 0.0;
            _isPlaying = false;
            timer.cancel();
          }
        });
      });
    } else {
      _progressTimer?.cancel();
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _onSeek(double value) {
    setState(() {
      _progress = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double imageSize = size.width * 0.15 > 80 ? 80 : size.width * 0.15;
    final double playerImageSize =
        size.width * 0.12 > 60 ? 60 : size.width * 0.12;
    final double fontSizeTitle = size.width * 0.05;
    final double fontSizeSubtitle = size.width * 0.035;
    final genres = ['Jazz', 'Rock', 'Romance'];

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(size.width * 0.02),
          child: Icon(
            Icons.music_note,
            size: size.width * 0.09,
            color: Colors.deepOrange,
          ),
        ),
        title: Text(
          'Maraponga Music',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSizeTitle,
          ),
        ),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Text('Username', style: TextStyle(fontSize: fontSizeSubtitle)),
              SizedBox(width: size.width * 0.02),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                  size: fontSizeSubtitle * 1.2,
                ),
              ),
              SizedBox(width: size.width * 0.04),
            ],
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.015,
              horizontal: size.width * 0.02,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...genres.map((genre) {
                  final isSelected = selectedGenre == genre;
                  return ChoiceChip(
                    label: Text(
                      genre,
                      style: TextStyle(fontSize: fontSizeSubtitle),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.deepOrange.withOpacity(0.5),
                    onSelected: (_) {
                      setState(() => selectedGenre = genre);
                    },
                    backgroundColor: const Color(0xFF232323),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  );
                }),
                Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: fontSizeTitle,
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return PlaylistCard(
                    title: playlist['title'],
                    artist: playlist['artist'],
                    items: playlist['items'],
                    duration: playlist['duration'],
                    image: playlist['image'],
                    imageSize: imageSize,
                    fontSizeTitle: fontSizeTitle,
                    fontSizeSubtitle: fontSizeSubtitle,
                    size: size,
                    selected: _selectedPlaylist == index,
                    onTap: () => _onPlaylistTap(index),
                  );
                },
              ),
            ),
          ),
          ActualSongCard(
            title: playlists[_selectedPlaylist]['title'],
            artist: playlists[_selectedPlaylist]['artist'],
            image: playlists[_selectedPlaylist]['image'],
            imageSize: playerImageSize,
            fontSizeTitle: fontSizeTitle,
            fontSizeSubtitle: fontSizeSubtitle,
            size: size,
            progress: _progress,
            onSeek: _onSeek,
            isPlaying: _isPlaying,
            onPlayPause: _togglePlayPause,
            isFavorite: _isFavorite,
            onFavorite: _toggleFavorite,
          ),
        ],
      ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}
