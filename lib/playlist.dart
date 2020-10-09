import 'package:cloud_firestore/cloud_firestore.dart';

class Playlist {
  final String name;
  final String playlistId;
  Playlist._({this.name, this.playlistId});
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return new Playlist._(
      name: json['name'],
      playlistId: json['playlistId'],
    );
  }
}

class SpotifyTrack {
  final String name;
  final String trackId;
  SpotifyTrack._({this.name, this.trackId});
  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return new SpotifyTrack._(
      name: json['name'],
      trackId: json['id'],
    );
  }
}

class Record {
  final String artist;
  final String title;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['artist'] != null),
        assert(map['title'] != null),
        artist = map['artist'],
        title = map['title'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$artist:$title>";
}