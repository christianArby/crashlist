part of 'playlist_cubit.dart';

abstract class PlaylistState extends Equatable {
  const PlaylistState();
}

class PlaylistInitial extends PlaylistState {
  @override
  List<Object> get props => [];
}

class PlaylistLoading extends PlaylistState {
  const PlaylistLoading();
  @override
  List<Object> get props => [];
}

class PlaylistLoaded extends PlaylistState {
  final PlaylistData playlistData;
  const PlaylistLoaded(this.playlistData);
  @override
  List<Object> get props => [playlistData];
}

class PlaylistError extends PlaylistState {
  final String message;
  const PlaylistError(this.message);
  @override
  List<Object> get props => [message];
}