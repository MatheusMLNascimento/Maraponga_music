import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service/player_provider.dart';
import 'components/actual_song_card.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/library_page.dart';
import 'pages/actual_song_page.dart';

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
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/search': (context) => const SearchPage(),
        '/library': (context) => const LibraryPage(),
        '/actual_song': (context) => const ActualSongPage(),
        // Adicione outras rotas conforme necessário
      },
      // Adiciona o ActualSongCard fixo acima da navigation bar
      builder: (context, child) {
        // Garante que o ActualSongCard tenha acesso ao Navigator usando Builder
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: Builder(
                builder: (context) => ActualSongCard(),
              ),
            ),
          ],
        );
      },
    );
  }
}