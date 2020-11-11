
part of 'list_cubit.dart'; 

@immutable
abstract class ListState extends Equatable {
  const ListState();
}

class ListInitial extends ListState {
  @override
  List<Object> get props => [];
}

class ListLoading extends ListState {
  const ListLoading();
  @override
  List<Object> get props => [];
}

class ListLoaded extends ListState {
  final Playlists playlists;
  const ListLoaded(this.playlists);
  @override
  List<Object> get props => [playlists];
}

class ListError extends ListState {
  final String message;
  const ListError(this.message);
  @override
  List<Object> get props => [message];
}