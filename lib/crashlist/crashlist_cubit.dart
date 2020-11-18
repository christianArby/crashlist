import 'package:bloc/bloc.dart';
import 'package:crashlist/crashlist/firebase_playlist.dart';
import 'package:crashlist/firebase_repository.dart';
import 'package:crashlist/player_repository.dart';
import 'package:crashlist/playlist/playlist.dart';
import 'package:crashlist/spotify_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

part 'crashlist_state.dart';

class CrashlistCubit extends Cubit<CrashlistState> {
  final FirebaseRepository firebaseRepository;
  final PlayerRepository playerRepository;
  CrashlistCubit(
      this.firebaseRepository, this.playerRepository)
      : super(CrashlistInitial());

  void updateCrashlist() {
    emit(CrashlistLoading());
    // TODO check if dispose is necessary
    firebaseRepository.crashlistStream.listen((event) {
      emit(CrashlistLoaded(event));
    });
  }

  void play(String playUri) {
    playerRepository.play(playUri);
  }

  void setOrder(List<String> orderArray) {
    firebaseRepository.updateOrder(orderArray);
  }

  void dismissed(List<String> orderArray) {
    setOrder(orderArray);
  }
}