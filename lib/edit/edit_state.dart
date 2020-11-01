part of 'edit_cubit.dart';

abstract class EditState extends Equatable {
  const EditState();
}

class EditInitial extends EditState {
  @override
  List<Object> get props => [];
}

class EditLoading extends EditState {
  const EditLoading();
  @override
  List<Object> get props => [];
}

class EditLoaded extends EditState {
  final FirebasePlaylist firebasePlaylist;
  const EditLoaded(this.firebasePlaylist);
  @override
  List<Object> get props => [firebasePlaylist];
}

class EditSaved extends EditState {
  const EditSaved();
  @override
  List<Object> get props => [];
}
