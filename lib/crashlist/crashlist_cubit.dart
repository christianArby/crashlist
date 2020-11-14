import 'package:bloc/bloc.dart';
import 'package:crashlist/crashlist/firebase_playlist.dart';
import 'package:crashlist/firebase_repository.dart';
import 'package:equatable/equatable.dart';

part 'crashlist_state.dart';

class CrashlistCubit extends Cubit<CrashlistState> {
  final FirebaseRepository firebaseRepository;
  CrashlistCubit(this.firebaseRepository) : super(CrashlistInitial());

  void updateCrashlist() {

    emit(CrashlistLoading());
    // TODO check if dispose is necessary
    firebaseRepository.crashlistStream.listen((event) {
      emit(CrashlistLoaded(event));
    });
  }
}
