import 'package:app/pages/queue_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service/player_provider.dart';
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
        '/queue': (context) => const QueuePage(),
        // Adicione outras rotas conforme necessário
      },
      
    );
  }
}