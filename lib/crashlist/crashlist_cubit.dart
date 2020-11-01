import 'package:bloc/bloc.dart';
import 'package:crashlist/crashlist/firebase_playlist.dart';
import 'package:crashlist/firebase_repository.dart';
import 'package:equatable/equatable.dart';

part 'crashlist_state.dart';

class CrashlistCubit extends Cubit<CrashlistState> {
  final FirebaseRepository firebaseRepository;
  CrashlistCubit(this.firebaseRepository) : super(CrashlistInitial());

  void updateCrashlist() {

    try {
      emit(CrashlistLoading());
      firebaseRepository.fetchCurrentPlaylist().listen((firebasePlaylist) { 
        emit(CrashlistLoaded(firebasePlaylist));
      });
    } on Exception {
      // Do something
    }
  }
}
