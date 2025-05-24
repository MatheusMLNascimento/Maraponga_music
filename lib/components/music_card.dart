import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/local_database.dart';
import '../service/player_provider.dart';

class MusicCard extends StatefulWidget {
  final dynamic song;
  final VoidCallback? onPlay;
  final bool showRemoveFromPlaylist;
  final String? playlistId;

  const MusicCard({
    super.key,
    required this.song,
    this.onPlay,
    this.showRemoveFromPlaylist = false,
    this.playlistId,
  });

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  bool get isFavorite {
    final db = LocalDatabase();
    final favPlaylist = db.getAllPlaylists().firstWhere(
      (p) => p.title.toLowerCase() == 'favoritos',
      orElse: () => PlaylistData(
        id: '',
        title: '',
        artist: '',
        image: '',
        songs: [],
      ),
    );
    return favPlaylist.songs.any((s) => s.id == widget.song.id);
  }

  Future<void> _toggleFavorite() async {
    final db = LocalDatabase();
    final favPlaylist = db.getAllPlaylists().firstWhere(
      (p) => p.title.toLowerCase() == 'favoritos',
      orElse: () => PlaylistData(
        id: '',
        title: '',
        artist: '',
        image: '',
        songs: [],
      ),
    );
    final alreadyFavorite = favPlaylist.songs.any((s) => s.id == widget.song.id);
    if (alreadyFavorite) {
      await db.removeSongFromPlaylist(favPlaylist.id, widget.song.id);
    } else {
      await db.addSongToPlaylist(favPlaylist.id, widget.song);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context, listen: false);
    final currentTrack = Provider.of<PlayerProvider>(context).currentTrack;

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          widget.song.image,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.music_note,
            color: Colors.white,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.song.title,
              style: TextStyle(
                color: (currentTrack != null && currentTrack.id == widget.song.id)
                    ? Colors.deepOrange
                    : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.deepOrange,
                  size: 22,
                ),
                padding: const EdgeInsets.only(right: 2),
                constraints: const BoxConstraints(),
                onPressed: _toggleFavorite,
              ),
              SizedBox(width: 1),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'add_to_queue') {
                    player.addToQueue([widget.song]);
                  } else if (value == 'save_to_playlist') {
                    final db = LocalDatabase();
                    final playlists = db.getAllPlaylists();
                    final selected = await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        backgroundColor: Colors.black,
                        title: const Text('Salvar na playlist', style: TextStyle(color: Colors.white)),
                        children: playlists
                            .map((p) => SimpleDialogOption(
                                  onPressed: () => Navigator.pop(context, p.id),
                                  child: Text(p.title, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                      ),
                    );
                    if (selected != null) {
                      await db.addSongToPlaylist(selected, widget.song);
                      setState(() {});
                    }
                  } else if (value == 'remove_from_playlist' && widget.showRemoveFromPlaylist && widget.playlistId != null) {
                    await LocalDatabase().removeSongFromPlaylist(widget.playlistId!, widget.song.id);
                    setState(() {});
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'add_to_queue',
                    child: Text('Adicionar à fila'),
                  ),
                  const PopupMenuItem(
                    value: 'save_to_playlist',
                    child: Text('Salvar na playlist'),
                  ),
                  if (widget.showRemoveFromPlaylist && widget.playlistId != null)
                    const PopupMenuItem(
                      value: 'remove_from_playlist',
                      child: Text('Remover da playlist'),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
      subtitle: Text(
        '${widget.song.artist} • ${widget.song.duration}',
        style: const TextStyle(color: Colors.white70),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // SearchPage: adiciona a música após a atual na fila e toca imediatamente
        if (ModalRoute.of(context)?.settings.name == '/search') {
          final queue = List<Song>.from(player.queue);
          final currentIndex = player.queueIndex;
          queue.removeWhere((s) => s.id == widget.song.id);
          final insertIndex = currentIndex + 1;
          queue.insert(insertIndex > queue.length ? queue.length : insertIndex, widget.song);
          player.setQueue(queue);
          player.setCurrentTrack(widget.song);
        } else if (widget.onPlay != null) {
          widget.onPlay!();
        }
      },
    );
  }
}
