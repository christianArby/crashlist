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

class Track {
  final String name;
  final String trackId;
  Track._({this.name, this.trackId});
  factory Track.fromJson(Map<String, dynamic> json) {
    return new Track._(
      name: json['name'],
      trackId: json['trackId'],
    );
  }
}