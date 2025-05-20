import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service/player_provider.dart';
import 'components/actual_song_card.dart';
import 'home_page.dart';

// Entry point do app, inicializa o Provider global do player
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PlayerProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget raiz do app, define tema e layout global
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maraponga Music',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
      ),
      home: const HomePage(), // Corrigido: use const HomePage()
      debugShowCheckedModeBanner: false,
      // Adiciona o ActualSongCard fixo acima da navigation bar
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 56, // altura típica do BottomNavigationBar
              child: ActualSongCard(),
            ),
          ],
        );
      },
    );
  }
}