import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../service/player_provider.dart';
import '../service/local_database.dart';

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

  @override
  void initState() {
    super.initState();
    final player = Provider.of<PlayerProvider>(context, listen: false);
    _progress = player.progress;
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final player = Provider.of<PlayerProvider>(context, listen: false);
    if (!mounted) return;
    if (player.isPlaying) {
      setState(() {
        _progress = player.progress;
      });
    }
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
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);
    final currentTrack = player.currentTrack;
    if (currentTrack == null) return const SizedBox.shrink();

    String artistText = '';
    final artists = currentTrack.artist.split(' e ');
    if (artists.length > 2) {
      artistText = '${artists[0]}, ${artists[1]}, ...';
    } else {
      artistText = currentTrack.artist;
    }

    // Define db and get favoritos playlist
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

    // Corrigido: Garante Overlay usando Material acima do Card, não dentro
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              if (Navigator.of(context, rootNavigator: true).canPop() ||
                  ModalRoute.of(context)?.isCurrent == true) {
                Navigator.of(context).pushNamed('/actual_song');
              }
            },
            child: Card(
              color: const Color.fromARGB(221, 41, 41, 41),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child:
                    Row(
                      children: [
                        Image.asset(
                          currentTrack.image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(width: 8),
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

                              // O Slider precisa de Overlay acima do MaterialApp, então use um Builder para garantir contexto correto
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}
