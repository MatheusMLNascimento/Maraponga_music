// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PlaylistCard extends StatelessWidget {
  final String title;
  final String artist;
  final int items;
  final String duration;
  final String image;
  final double imageSize;
  final double fontSizeTitle;
  final double fontSizeSubtitle;
  final Size size;
  final bool selected;
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.title,
    required this.artist,
    required this.items,
    required this.duration,
    required this.image,
    required this.imageSize,
    required this.fontSizeTitle,
    required this.fontSizeSubtitle,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget? selectedImage;
    if (selected) {
      selectedImage = Image.asset(
        'assets/actualsong.png', 
        width: fontSizeSubtitle * 1.8,
        height: fontSizeSubtitle * 1.8,
        color: Colors.deepOrange,
        colorBlendMode: BlendMode.srcIn,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        vertical: size.height * 0.007,
        horizontal: size.width * 0.02,
      ),
      padding: EdgeInsets.all(size.width * 0.02),
      decoration: BoxDecoration(
        color:
            selected
                ? Colors.deepOrange.withOpacity(0.15)
                : const Color(0xFF232323),
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            selected
                ? [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.5),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
                : [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Row(
          children: [
            Image.asset(
              image,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeTitle,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    artist,
                    style: TextStyle(
                      fontSize: fontSizeSubtitle,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$items itens',
                  style: TextStyle(
                    fontSize: fontSizeSubtitle,
                    color: Colors.white,
                  ),
                ),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: fontSizeSubtitle,
                    color: Colors.white,
                  ),
                ),
                if (selectedImage != null) selectedImage,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActualSongCard extends StatelessWidget {
  final String title;
  final String artist;
  final String image;
  final double imageSize;
  final double fontSizeTitle;
  final double fontSizeSubtitle;
  final Size size;
  final double progress;
  final ValueChanged<double> onSeek;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const ActualSongCard({
    super.key,
    required this.title,
    required this.artist,
    required this.image,
    required this.imageSize,
    required this.fontSizeTitle,
    required this.fontSizeSubtitle,
    required this.size,
    required this.progress,
    required this.onSeek,
    required this.isPlaying,
    required this.onPlayPause,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF232323),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical: size.height * 0.004,
      ),
      margin: EdgeInsets.symmetric(
        vertical: size.height * 0.015,
        horizontal: size.width * 0.02,
      ),

      child: Row(
        children: <Widget>[
          Image.asset(
            image,
            width: size.width * 0.18,
            height: size.height * 0.085,
            fit: BoxFit.cover,
          ),
          SizedBox(width: size.width * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeTitle,
                    color: Colors.white,
                  ),
                ),
                Text(
                  artist,
                  style: TextStyle(
                    fontSize: fontSizeSubtitle,
                    color: Colors.white70,
                  ),
                ),
                Slider(
                  value: progress,
                  onChanged: onSeek,
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFavorite ? Colors.deepOrange : Colors.white,
              size: fontSizeTitle,
            ),
            onPressed: onFavorite,
          ),
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: fontSizeTitle * 1.5,
            ),
            onPressed: onPlayPause,
          ),
        ],
      ),
    );
  }
}
