import 'package:app/service/local_database.dart';
import 'package:flutter/material.dart';
import '../components/playlist_card.dart';

// Provider global para controlar o estado do player (música/playlist atual, progresso, etc)
class PlayerProvider extends ChangeNotifier {
  Playlist? _playlist;
  Song? _currentTrack;
  List<Song> _queue = [];
  int _queueIndex = 0;
  bool _isPlaying = false;
  bool _isFavorite = false;
  double _progress = 0.0;

  Playlist? get playlist => _playlist;
  Song? get currentTrack => _currentTrack;
  List<Song> get queue => List.unmodifiable(_queue);
  int get queueIndex => _queueIndex;
  bool get isPlaying => _isPlaying;
  bool get isFavorite => _isFavorite;
  double get progress => _progress;

  // Define a fila de músicas e reseta o índice
  void setQueue(List<Song> songs) {
    _queue = List<Song>.from(songs);
    _queueIndex = 0;
    notifyListeners();
  }

  // Adiciona músicas ao final da fila
  void addToQueue(List<Song> songs) {
    _queue.addAll(songs);
    notifyListeners();
  }

  // Define a playlist (apenas referência, não afeta fila)
  void setPlaylist(Playlist playlist) {
    _playlist = playlist;
    notifyListeners();
  }

  // Define a música atual e atualiza o índice na fila se existir
  void setCurrentTrack(Song song) {
    _currentTrack = song;
    _isPlaying = true;
    notifyListeners();
  }

  // Próxima música na fila
  void playNext() {
    if (_queue.isNotEmpty && _queueIndex < _queue.length - 1) {
      _queueIndex++;
      _currentTrack = _queue[_queueIndex];
      _isPlaying = true;
      notifyListeners();
    }
  }

  // Música anterior na fila
  void playPrevious() {
    if (_queue.isNotEmpty && _queueIndex > 0) {
      _queueIndex--;
      _currentTrack = _queue[_queueIndex];
      _isPlaying = true;
      notifyListeners();
    }
  }

  // Play/pause
  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  // Progresso da música
  void setProgress(double value) {
    _progress = value;
    notifyListeners();
  }

  // Favoritar/desfavoritar
  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }
}
