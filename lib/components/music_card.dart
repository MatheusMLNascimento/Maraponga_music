import 'package:flutter/material.dart';

// Card visual para exibir uma música na lista
class MusicCard extends StatelessWidget {
  final String title;
  final String artist;
  final String duration;
  final String image;
  final bool selected;
  final VoidCallback onTap;
  final Size size;

  const MusicCard({
    super.key,
    required this.title,
    required this.artist,
    required this.duration,
    required this.image,
    required this.selected,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? Colors.deepOrange.withAlpha(128) : Colors.grey[900],
      child: ListTile(
        leading: Image.asset(
          image,
          width: size.width * 0.15,
          height: size.width * 0.15,
          fit: BoxFit.cover,
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '$artist • $duration',
          style: const TextStyle(color: Colors.white70),
        ),
        onTap: onTap,
        selected: selected,
        selectedTileColor: Colors.deepOrange.withAlpha(128),
      ),
    );
  }
}
