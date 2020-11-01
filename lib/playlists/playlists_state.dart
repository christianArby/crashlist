
part of '../playlists/playlists_cubit.dart'; 

@immutable
abstract class PlaylistsState extends Equatable {
  const PlaylistsState();
}

class PlaylistsInitial extends PlaylistsState {
  @override
  List<Object> get props => [];
}

class PlaylistsLoading extends PlaylistsState {
  const PlaylistsLoading();
  @override
  List<Object> get props => [];
}

class PlaylistsLoaded extends PlaylistsState {
  final Playlists playlists;
  const PlaylistsLoaded(this.playlists);
  @override
  List<Object> get props => [playlists];
}

class PlaylistsError extends PlaylistsState {
  final String message;
  const PlaylistsError(this.message);
  @override
  List<Object> get props => [message];
}