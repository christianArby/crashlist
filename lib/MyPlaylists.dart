class MyPlaylists {
  final List playlistNames;

  MyPlaylists({this.playlistNames});

  factory MyPlaylists.fromJson(List json) {
    return MyPlaylists(
      playlistNames: json,
    );
  }
}