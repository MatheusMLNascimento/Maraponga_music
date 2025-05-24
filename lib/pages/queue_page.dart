import 'package:app/components/actual_song_card.dart';
import 'package:app/components/music_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/player_provider.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);
    final queue = player.queue;

    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! > 10) {
                  Navigator.of(context).maybePop();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(235, 41, 41, 41),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height * 0.60,
                child: NotificationListener<DraggableScrollableNotification>(
                  onNotification: (_) => true,
                  child: Column(
                    children: [
                      Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerMove: (event) {
                          if (event.delta.dy > 10) {
                            Navigator.of(context).maybePop();
                          }
                        },
                        child: ActualSongCard(),
                      ),

                      Expanded(
                        child: queue.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhuma música na fila',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            : ListView.builder(
                                itemCount: queue.length,
                                itemBuilder: (context, index) {
                                  final song = queue[index];
                                  return MusicCard(
                                    song: song,
                                    onPlay: () {
                                      player.setCurrentTrack(song);
                                    },
                                    showRemoveFromPlaylist: false,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
