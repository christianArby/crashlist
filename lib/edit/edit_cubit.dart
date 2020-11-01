import 'package:bloc/bloc.dart';
import 'package:crashlist/crashlist/firebase_playlist.dart';
import 'package:crashlist/firebase_repository.dart';
import 'package:equatable/equatable.dart';

part 'edit_state.dart';

class EditCubit extends Cubit<EditState> {
  final FirebaseRepository firebaseRepository;
  EditCubit(this.firebaseRepository) : super(EditInitial());

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

  Future<void> saveEdit() async {
    try {
      emit(EditLoading());
      sleep5().then((value) =>
          firebaseRepository.fetchCurrentPlaylist().listen((firebasePlaylist) {
            emit(EditSaved());
          }));
    } on Exception {}
  }

  Future sleep5() {
    return new Future.delayed(const Duration(seconds: 5), () => "5");
  }
}
