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
  final String id;
  final String name;
  final String uri;
  var tempAuth;
  final DocumentReference reference;
  SpotifyTrack._({this.id, this.name, this.uri, this.tempAuth, this.reference});
  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return new SpotifyTrack._(
      id: json['id'],
      name: json['name'],
      uri: json['uri'],
      tempAuth: null,
      reference: null,
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'uri': uri,
        'tempAuth': tempAuth
      };


  SpotifyTrack.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['id'] != null),
        assert(map['name'] != null),
        assert(map['uri'] != null),
        id = map['id'],
        name = map['name'],
        uri = map['uri'],
        tempAuth = null;

  SpotifyTrack.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}
