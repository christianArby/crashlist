import 'package:crashlist/playlists/playlist_minimal.dart';
import 'package:equatable/equatable.dart';

class Playlists extends Equatable {
final List<PlaylistMinimal> playlists;

  Playlists(this.playlists);

  @override
  List<Object> get props => [playlists];
}