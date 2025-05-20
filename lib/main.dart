import 'package:flutter/material.dart';
import 'home_page.dart'; // Make sure this file exists and exports a HomePage widget

void main() {
  runApp(MarapongaMusicApp());
}

class MarapongaMusicApp extends StatelessWidget {
  const MarapongaMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maraponga Music',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}