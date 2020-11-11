import 'package:crashlist/list/playlist_minimal.dart';
import 'package:equatable/equatable.dart';

class Playlists extends Equatable {
final List<PlaylistMinimal> playlists;

  Playlists(this.playlists);

  @override
  List<Object> get props => [playlists];
}