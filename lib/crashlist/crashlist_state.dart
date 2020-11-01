part of 'crashlist_cubit.dart';

abstract class CrashlistState extends Equatable {
  const CrashlistState();
}

class CrashlistInitial extends CrashlistState {
  @override
  List<Object> get props => [];
}

class CrashlistLoading extends CrashlistState {
  const CrashlistLoading();
  @override
  List<Object> get props => [];
}

class CrashlistLoaded extends CrashlistState {
  final FirebasePlaylist firebasePlaylist;
  const CrashlistLoaded(this.firebasePlaylist);
  @override
  List<Object> get props => [firebasePlaylist];
}
