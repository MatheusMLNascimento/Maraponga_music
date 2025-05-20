// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'playlist_card.dart';

class SearchResultCard extends StatelessWidget {
  final Playlist item;
  const SearchResultCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF232323),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: ListTile(
        leading: Image.asset(
          item.image,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          item.artist,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        trailing: item.items != null && item.items > 1
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${item.items} itens',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    item.duration,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              )
            : Text(
                item.duration,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }
}
