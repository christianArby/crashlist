part of 'player_view_cubit.dart';

abstract class PlayerViewState extends Equatable {
  const PlayerViewState();
}

class PlayerViewInitial extends PlayerViewState {
  @override
  List<Object> get props => [];
}

class PlayerViewLoaded extends PlayerViewState {
  final PlayerState playerState;
  const PlayerViewLoaded(this.playerState);
  @override
  List<Object> get props => [playerState];
}


