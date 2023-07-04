import 'dart:convert';

class Music {
  final String musicTitle;
  final List<String> musicArtists;
  final String musicAlbum;
  final int score;
  final String status;

  Music({
    required this.musicTitle,
    required this.musicArtists,
    required this.musicAlbum,
    required this.score,
    required this.status,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      musicTitle: json['data']['title'],
      musicArtists: List<String>.from(json['data']['artists']),
      musicAlbum: json['data']['album'],
      score: json['data']['score'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'title': musicTitle,
        'artists': musicArtists,
        'album': musicAlbum,
        'score': score,
      },
      'status': status,
    };
  }
}
