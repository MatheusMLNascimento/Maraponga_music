import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Modelo de música
class Song {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String image;
  final List<String> genres; // NOVO: lista de gêneros

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.image,
    required this.genres,
  });
}

// Modelo de playlist
class PlaylistData {
  final String id;
  String title;
  String artist;
  String image;
  List<Song> songs;
  DateTime lastAccess; // NOVO: último acesso

  PlaylistData({
    required this.id,
    required this.title,
    required this.artist,
    required this.image,
    required this.songs,
    DateTime? lastAccess,
  }) : lastAccess = lastAccess ?? DateTime.now();

  int get items => songs.length;
  String get duration {
    int totalSeconds = songs.fold(0, (sum, song) {
      final parts = song.duration.split(':');
      return sum + int.parse(parts[0]) * 60 + int.parse(parts[1]);
    });
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  final List<Song> _songs = [];
  final List<PlaylistData> _playlists = [];

  // Caminho do arquivo JSON local
  Future<File> get _playlistFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/playlists.json');
  }

  // Inicializa banco: carrega playlists do storage e gera músicas
  Future<void> init() async {
    _generateSongs();
    await _loadPlaylists();
    if (_playlists.isEmpty) {
      _generateDefaultPlaylists();
      await _savePlaylists();
    }
    _ensureFavoritesPlaylist();
  }

  // Gera músicas reais com artistas reais e imagens específicas
  void _generateSongs() {
    if (_songs.isNotEmpty) return;
    final songData = [
      // Supercombo
      {'title': 'Amianto', 'artist': 'Supercombo', 'duration': '3:05', 'image': 'assets/amianto.png', 'genres': ['Rock', 'Indie', 'Alternativo']},
      {'title': 'Piloto Automático', 'artist': 'Supercombo', 'duration': '3:30', 'image': 'assets/amianto.png', 'genres': ['Rock', 'Pop', 'Alternativo']},
      {'title': 'Sol da Manhã', 'artist': 'Supercombo', 'duration': '4:12', 'image': 'assets/amianto.png', 'genres': ['Rock', 'Indie']},
      {'title': 'Gravidade', 'artist': 'Supercombo', 'duration': '3:45', 'image': 'assets/amianto.png', 'genres': ['Rock', 'Alternativo']},
      {'title': 'Labirinto', 'artist': 'Supercombo', 'duration': '2:58', 'image': 'assets/amianto.png', 'genres': ['Rock', 'Indie']},
      // Chrono
      {'title': 'O Último Romântico', 'artist': 'Chrono', 'duration': '3:40', 'image': 'assets/adeus_aurora.png', 'genres': ['Pop', 'Indie', 'Nacional']},
      {'title': 'Caminho Sem Volta', 'artist': 'Chrono', 'duration': '4:01', 'image': 'assets/adeus_aurora.png', 'genres': ['Pop', 'Folk']},
      {'title': 'Além do Horizonte', 'artist': 'Chrono', 'duration': '3:15', 'image': 'assets/adeus_aurora.png', 'genres': ['Pop', 'Indie']},
      {'title': 'Vento', 'artist': 'Chrono', 'duration': '2:50', 'image': 'assets/adeus_aurora.png', 'genres': ['Folk', 'Indie']},
      // M4rkim
      {'title': 'Rogério', 'artist': 'M4rkim', 'duration': '3:55', 'image': 'assets/rogerio.png', 'genres': ['Rap', 'Trap', 'Nacional']},
      {'title': 'Infame', 'artist': 'M4rkim', 'duration': '4:20', 'image': 'assets/infame.png', 'genres': ['Rap', 'Trap']},
      {'title': 'Aurora', 'artist': 'M4rkim', 'duration': '3:33', 'image': 'assets/adeus_aurora.png', 'genres': ['Rap', 'Pop']},
      // Outros artistas
      {'title': 'Shape of You', 'artist': 'Ed Sheeran', 'duration': '3:53', 'image': 'assets/mega_mix.png', 'genres': ['Pop', 'Folk', 'Internacional']},
      {'title': 'Blinding Lights', 'artist': 'The Weeknd', 'duration': '3:20', 'image': 'assets/mega_mix.png', 'genres': ['Pop', 'Internacional']},
      {'title': 'Bohemian Rhapsody', 'artist': 'Queen', 'duration': '5:55', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Clássico', 'Internacional']},
      {'title': 'Smells Like Teen Spirit', 'artist': 'Nirvana', 'duration': '5:01', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Alternativo', 'Internacional']},
      {'title': 'Billie Jean', 'artist': 'Michael Jackson', 'duration': '4:54', 'image': 'assets/mega_mix.png', 'genres': ['Pop', 'Internacional']},
      {'title': 'Imagine', 'artist': 'John Lennon', 'duration': '3:07', 'image': 'assets/mega_mix.png', 'genres': ['Clássico', 'Folk', 'Internacional']},
      {'title': 'Hey Jude', 'artist': 'The Beatles', 'duration': '7:11', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Clássico', 'Internacional']},
      {'title': 'Let It Be', 'artist': 'The Beatles', 'duration': '4:03', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Clássico', 'Internacional']},
      {'title': 'Hotel California', 'artist': 'Eagles', 'duration': '6:30', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Folk', 'Internacional']},
      {'title': 'Wonderwall', 'artist': 'Oasis', 'duration': '4:18', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Pop', 'Internacional']},
      {'title': 'Stairway to Heaven', 'artist': 'Led Zeppelin', 'duration': '8:02', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Clássico', 'Internacional']},
      {'title': 'Sweet Child O\' Mine', 'artist': 'Guns N\' Roses', 'duration': '5:56', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Clássico', 'Internacional']},
      {'title': 'Lose Yourself', 'artist': 'Eminem', 'duration': '5:26', 'image': 'assets/mega_mix.png', 'genres': ['Rap', 'Internacional']},
      {'title': 'Rolling in the Deep', 'artist': 'Adele', 'duration': '3:48', 'image': 'assets/mega_mix.png', 'genres': ['Pop', 'Internacional']},
      {'title': 'Viva La Vida', 'artist': 'Coldplay', 'duration': '4:02', 'image': 'assets/mega_mix.png', 'genres': ['Pop', 'Rock', 'Internacional']},
      {'title': 'Counting Stars', 'artist': 'OneRepublic', 'duration': '4:17', 'image': 'assets/mega_mix.png', 'genres': ['Pop', 'Rock', 'Internacional']},
      {'title': 'Radioactive', 'artist': 'Imagine Dragons', 'duration': '3:06', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Pop', 'Internacional']},
      {'title': 'Believer', 'artist': 'Imagine Dragons', 'duration': '3:24', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Pop', 'Internacional']},
      {'title': 'Happier', 'artist': 'Marshmello', 'duration': '3:34', 'image': 'assets/mega_mix.png', 'genres': ['Pop', 'Internacional']},
      {'title': 'Senhor do Tempo', 'artist': 'Projota', 'duration': '3:47', 'image': 'assets/mega_mix.png', 'genres': ['Rap', 'Nacional']},
      {'title': 'Dias de Luta, Dias de Glória', 'artist': 'Charlie Brown Jr.', 'duration': '3:44', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Rap', 'Nacional']},
      {'title': 'Me Adora', 'artist': 'Pitty', 'duration': '3:42', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Nacional']},
      {'title': 'Pra Você Dar o Nome', 'artist': '5 a Seco', 'duration': '3:37', 'image': 'assets/mega_mix.png', 'genres': ['MPB', 'Folk', 'Nacional']},
      {'title': 'Velha Infância', 'artist': 'Tribalistas', 'duration': '4:29', 'image': 'assets/mega_mix.png', 'genres': ['MPB', 'Folk', 'Nacional']},
      {'title': 'Anna Júlia', 'artist': 'Los Hermanos', 'duration': '4:30', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'MPB', 'Nacional']},
      {'title': 'Tempo Perdido', 'artist': 'Legião Urbana', 'duration': '6:39', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Nacional']},
      {'title': 'Pais e Filhos', 'artist': 'Legião Urbana', 'duration': '5:06', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'Nacional']},
      {'title': 'Exagerado', 'artist': 'Cazuza', 'duration': '3:27', 'image': 'assets/mega_mix.png', 'genres': ['Rock', 'MPB', 'Nacional']},
    ];

    for (int i = 0; i < songData.length; i++) {
      final data = songData[i];
      _songs.add(Song(
        id: 'song_$i',
        title: data['title'] as String,
        artist: data['artist'] as String,
        duration: data['duration'] as String,
        image: data['image'] as String,
        genres: (data['genres'] as List<dynamic>).map((e) => e as String).toList(),
      ));
    }
  }

  // Gêneros possíveis
  static const List<String> allGenres = [
    'Rock', 'Pop', 'Indie', 'MPB', 'Rap', 'Trap', 'Folk', 'Alternativo', 'Clássico', 'Internacional', 'Nacional'
  ];

  // NOVO: retorna todos os gêneros únicos das músicas
  List<String> getAllGenres() {
    final genresSet = <String>{};
    for (final song in _songs) {
      genresSet.addAll(song.genres);
    }
    return genresSet.toList()..sort();
  }

  // NOVO: busca músicas por gênero (duplicated, removed to fix error)
  // List<Song> searchSongsByGenre(String genre) {
  //   return _songs.where((song) => song.genres.contains(genre)).toList();
  // }

  // Gera playlists padrão (apenas se não houver playlists salvas)
  void _generateDefaultPlaylists() {
    _playlists.clear();
    _playlists.add(PlaylistData(
      id: 'playlist_0',
      title: 'Supercombo Hits',
      artist: 'Supercombo',
      image: 'assets/amianto.png',
      songs: _songs.where((s) => s.artist == 'Supercombo').toList(),
    ));
    _playlists.add(PlaylistData(
      id: 'playlist_1',
      title: 'Clássicos Internacionais',
      artist: 'Vários',
      image: 'assets/adeus_aurora.png',
      songs: _songs.where((s) =>
        [
          'Queen', 'The Beatles', 'Eagles', 'Oasis', 'Led Zeppelin', 'Guns N\' Roses',
          'Ed Sheeran', 'The Weeknd', 'Adele', 'Coldplay', 'OneRepublic',
          'Imagine Dragons', 'Eminem', 'John Lennon', 'Michael Jackson'
        ].contains(s.artist)
      ).toList(),
    ));
    _playlists.add(PlaylistData(
      id: 'playlist_2',
      title: 'Nacionais',
      artist: 'Vários',
      image: 'assets/rogerio.png',
      songs: _songs.where((s) =>
        [
          'Projota', 'Charlie Brown Jr.', 'Pitty', '5 a Seco', 'Tribalistas',
          'Los Hermanos', 'Legião Urbana', 'Cazuza'
        ].contains(s.artist)
      ).toList(),
    ));
  }

  // Garante que a playlist de favoritos existe
  void _ensureFavoritesPlaylist() {
    if (!_playlists.any((p) => p.id == 'favorites')) {
      _playlists.add(PlaylistData(
        id: 'favorites',
        title: 'Favoritos',
        artist: 'Favoritos',
        image: 'assets/mega_mix.png',
        songs: [],
      ));
    }
  }

  // Retorna as 5 playlists mais acessadas recentemente
  List<PlaylistData> getTop5Playlists() {
    final sorted = List<PlaylistData>.from(_playlists)
      ..sort((a, b) => b.lastAccess.compareTo(a.lastAccess));
    return sorted.take(5).toList();
  }

  List<Song> getAllSongs() => List.unmodifiable(_songs);

  List<PlaylistData> getAllPlaylists() => List.unmodifiable(_playlists);

  // Busca músicas por nome ou artista
  List<Song> searchSongs(String query) {
    final lower = query.toLowerCase();
    return _songs.where((song) =>
      song.title.toLowerCase().contains(lower) ||
      song.artist.toLowerCase().contains(lower)
    ).toList();
  }

  // Busca músicas por gênero
  List<Song> searchSongsByGenre(String genre) {
    return _songs.where((song) => song.genres.contains(genre)).toList();
  }

  // Adiciona música a uma playlist e salva no storage
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    if (!playlist.songs.any((s) => s.id == song.id)) {
      playlist.songs.add(song);
      await _savePlaylists();
    }
  }

  // Remove música de uma playlist e salva no storage
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.songs.removeWhere((s) => s.id == songId);
    await _savePlaylists();
  }

  // Cria uma nova playlist e salva no storage
  Future<PlaylistData> createPlaylist(String title, String desc, String image) async {
    final playlist = PlaylistData(
      id: 'playlist_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      artist: desc,
      image: image,
      songs: [],
    );
    _playlists.add(playlist);
    await _savePlaylists();
    return playlist;
  }

  // Remove uma playlist do banco e storage
  Future<void> removePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    await _savePlaylists();
  }

  // Atualiza o último acesso de uma playlist
  Future<void> updatePlaylistAccess(String playlistId) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId, orElse: () => _playlists.first);
    playlist.lastAccess = DateTime.now();
    await _savePlaylists();
  }

  // Adiciona música aos favoritos
  Future<void> addSongToFavorites(Song song) async {
    await addSongToPlaylist('favorites', song);
  }

  // Salva playlists em arquivo JSON local
  Future<void> _savePlaylists() async {
    final file = await _playlistFile;
    final data = _playlists.map((p) => {
      'id': p.id,
      'title': p.title,
      'artist': p.artist,
      'image': p.image,
      'lastAccess': p.lastAccess.toIso8601String(),
      'songs': p.songs.map((s) => {
        'id': s.id,
        'title': s.title,
        'artist': s.artist,
        'duration': s.duration,
        'image': s.image,
        'genres': s.genres,
      }).toList(),
    }).toList();
    await file.writeAsString(jsonEncode(data));
  }

  // Carrega playlists do arquivo JSON local
  Future<void> _loadPlaylists() async {
    final file = await _playlistFile;
    _playlists.clear();
    if (await file.exists()) {
      final content = await file.readAsString();
      final data = jsonDecode(content) as List;
      for (final p in data) {
        _playlists.add(PlaylistData(
          id: p['id'],
          title: p['title'],
          artist: p['artist'],
          image: p['image'],
          lastAccess: p['lastAccess'] != null ? DateTime.parse(p['lastAccess']) : DateTime.now(),
          songs: (p['songs'] as List).map((s) => Song(
            id: s['id'] as String,
            title: s['title'] as String,
            artist: s['artist'] as String,
            duration: s['duration'] as String,
            image: s['image'] as String,
            genres: (s['genres'] != null)
                ? (s['genres'] as List<dynamic>).map((e) => e as String).toList()
                : <String>[],
          )).toList(),
        ));
      }
    }
  }
}
