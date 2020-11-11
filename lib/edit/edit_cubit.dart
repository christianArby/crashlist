import 'package:bloc/bloc.dart';
import 'package:crashlist/crashlist/firebase_playlist.dart';
import 'package:crashlist/firebase_repository.dart';
import 'package:crashlist/spotify_repository.dart';
import 'package:equatable/equatable.dart';

part 'edit_state.dart';

class EditCubit extends Cubit<EditState> {
  final FirebaseRepository firebaseRepository;
  final SpotifyRepository spotifyRepository;
  

  EditCubit(this.firebaseRepository, this.spotifyRepository)
      : super(EditInitial());

  void updateEdit() {
    try {
      emit(EditLoading());
      firebaseRepository.fetchCurrentPlaylist().listen((firebasePlaylist) {
        emit(EditLoaded(firebasePlaylist));
      });
    } on Exception {
      // Do something
    }
  }

  Future<void> saveEdit(FirebasePlaylist firebasePlaylist) async {
    if (firebasePlaylist == null) {
      emit(EditSaved());
    }

    try {
      emit(EditLoading());

      spotifyRepository
          .replaceTracks(firebasePlaylist)
          .then((value) => emit(EditSaved()));
    } on Exception {
      emit(EditSaved());
    }
  }


  



}
