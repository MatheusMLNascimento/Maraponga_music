// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../service/player_provider.dart';
import '../service/local_database.dart';
import '../pages/queue_page.dart';

// Card fixo que mostra a música/playlist atualmente tocando
class ActualSongCard extends StatefulWidget {
  const ActualSongCard({super.key});

  @override
  State<ActualSongCard> createState() => _ActualSongCardState();
}

class _ActualSongCardState extends State<ActualSongCard>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _progress = 0.0;
  double _durationSeconds = 1.0;

  @override
  void initState() {
    super.initState();
    final player = Provider.of<PlayerProvider>(context, listen: false);
    _progress = player.progress;
    _durationSeconds = _getDurationInSeconds(player.currentTrack?.duration);
    _ticker = Ticker(_onTick)..start();
    _lastTick = DateTime.now();
  }

  DateTime _lastTick = DateTime.now();

  void _onTick(Duration elapsed) {
    final player = Provider.of<PlayerProvider>(context, listen: false);
    if (!mounted) return;

    // Atualiza duração e progresso reais a cada tick
    final durationSeconds = _getDurationInSeconds(player.currentTrack?.duration);
    final progressSeconds = player.progress;

    // Calcula o tempo real passado desde o último tick
    final now = DateTime.now();
    final delta = now.difference(_lastTick).inMilliseconds;
    _lastTick = now;

    setState(() {
      _durationSeconds = durationSeconds;
      _progress = progressSeconds;
    });

    if (player.isPlaying) {
      // Avança o progresso de acordo com o tempo real (em segundos)
      double increment = delta / 1000.0;
      double nextProgress = _progress + increment;

      if (nextProgress >= _durationSeconds && _durationSeconds > 0) {
        player.setProgress(0);
        player.playNext();
      } else {
        player.setProgress(nextProgress);
      }
    }
    // Se estiver pausado, não avança o slider
  }

  double _getDurationInSeconds(String? durationStr) {
    if (durationStr == null) return 1.0;
    final parts = durationStr.split(':');
    if (parts.length == 3) {
      // HH:MM:SS
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = int.tryParse(parts[2]) ?? 0;
      return (hours * 3600 + minutes * 60 + seconds).toDouble();
    } else if (parts.length == 2) {
      // MM:SS
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return (minutes * 60 + seconds).toDouble();
    }
    return 1.0;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _toggleFavorite(PlayerProvider player) async {
    final song = player.currentTrack;
    if (song == null) return;
    final db = LocalDatabase();
    PlaylistData favPlaylist;
    try {
      favPlaylist = db.getAllPlaylists().firstWhere(
        (p) => p.title.toLowerCase() == 'favoritos',
      );
    } catch (e) {
      favPlaylist = await db.createPlaylist(
        'Favoritos',
        'Músicas favoritas',
        song.image,
      );
    }
    final alreadyFavorite = favPlaylist.songs.any((s) => s.id == song.id);
    if (alreadyFavorite) {
      await db.removeSongFromPlaylist(favPlaylist.id, song.id);
    } else {
      await db.addSongToPlaylist(favPlaylist.id, song);
    }
    setState(() {});
    // Notifica para atualizar a HomePage se necessário
    if (Navigator.of(context).canPop()) {
      // Se não está na Home, notifica o ancestor
      Navigator.of(context).maybePop();
    } else {
      // Se está na Home, força rebuild
      (context as Element).markNeedsBuild();
    }
  }

  String? _lastSongId;

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);
    final currentTrack = player.currentTrack;
    if (currentTrack == null) return const SizedBox.shrink();

    // Atualiza _durationSeconds sempre que a música mudar
    final durationSeconds = _getDurationInSeconds(currentTrack.duration);

    // Identificador único da música atual
    final currentSongId = currentTrack.id;

    // Armazena o id da última música exibida
    // Se mudou a música, reseta o slider para 0 e sincroniza o progresso do player
    if (_durationSeconds != durationSeconds || _lastSongId != currentSongId) {
      _durationSeconds = durationSeconds;
      _progress = 0;
      player.setProgress(0);
      _lastSongId = currentSongId;
    } else {
      _durationSeconds = durationSeconds;
      _progress = player.progress;
    }

    String artistText = '';
    final artists = currentTrack.artist.split(' e ');
    if (artists.length > 2) {
      artistText = '${artists[0]}, ${artists[1]}, ...';
    } else {
      artistText = currentTrack.artist;
    }

    final db = LocalDatabase();
    PlaylistData? favPlaylist;
    try {
      favPlaylist = db.getAllPlaylists().firstWhere(
        (p) => p.title.toLowerCase() == 'favoritos',
      );
    } catch (e) {
      favPlaylist = null;
    }
    final isFavorite =
        favPlaylist != null &&
        favPlaylist.songs.any((s) => s.id == currentTrack.id);

    // GestureDetector para swipe e drag
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < 0) {
          // Swipe para esquerda: próxima música
          player.playNext();
        } else if (details.primaryVelocity! > 0) {
          // Swipe para direita: música anterior
          player.playPrevious();
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          // Arrastou para cima: abrir página da fila por cima da anterior
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              barrierColor: Colors.black.withValues(alpha: 0.3),
              pageBuilder: (_, __, ___) => const QueuePage(),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: anim,
                child: child,
              ),
            ),
          );
        }
      },
      child: Card(
        color: const Color.fromARGB(221, 41, 41, 41),
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.02,
          horizontal: MediaQuery.of(context).size.width * 0.009,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6), // Cantos mais arredondados
                    child: Image.asset(
                      currentTrack.image,
                      width: 60,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.music_note,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTrack.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          artistText,
                          style: const TextStyle(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.deepOrange,
                    ),
                    onPressed: () => _toggleFavorite(player),
                  ),
                  IconButton(
                    icon: Icon(
                      player.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: player.togglePlayPause,
                  ),
                ],
              ),
              SizedBox(height: 2),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  trackHeight: 2,
                  thumbColor: Colors.deepOrange,
                  activeTrackColor: Colors.deepOrange,
                  inactiveTrackColor: Colors.white24,
                ),
                child: Slider(
                  min: 0,
                  max: _durationSeconds > 0 ? _durationSeconds : 1,
                  value: _progress.clamp(0, _durationSeconds > 0 ? _durationSeconds : 1),
                  onChanged: (value) {
                    player.setProgress(value);
                    setState(() {
                      _progress = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}