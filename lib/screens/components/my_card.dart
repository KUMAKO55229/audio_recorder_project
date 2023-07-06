import 'package:ecade_mvp/models/music.dart';
import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final Music music;

  MyCard({required this.music});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      color: Color(0xFF089af8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                music.musicTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                'Artistas: ${music.musicArtists.join(", ")}',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                'Álbum: ${music.musicAlbum}',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
