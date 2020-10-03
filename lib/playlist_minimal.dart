class PlaylistMinimal {
  final String name;
  final String playlistId;
  PlaylistMinimal._({this.name, this.playlistId});
  factory PlaylistMinimal.fromJson(Map<String, dynamic> json) {
    return new PlaylistMinimal._(
      name: json['name'],
      playlistId: json['playlistId'],
    );
  }
}