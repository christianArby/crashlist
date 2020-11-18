import 'package:bloc/bloc.dart';
import 'package:crashlist/firebase_repository.dart';
import 'package:crashlist/playlist/playlist.dart';
import 'package:equatable/equatable.dart';

import '../spotify_repository.dart';

part 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
 final SpotifyRepository spotifyRepository;
 final FirebaseRepository firebaseRepository;

  PlaylistCubit(this.spotifyRepository, this.firebaseRepository) : super(PlaylistInitial());

  List<AddTrackData> tracksToBeAddedToSpotify = List.empty(growable: true);

  Future<void> getPlaylist(String playlistId) async {
    try {
      emit(PlaylistLoading());
      final playlistData = await spotifyRepository.fetchPlaylist(playlistId);
      emit(PlaylistLoaded(playlistData));
    } on Exception {
      emit(PlaylistError('Could not load playlists. Is the device online?'));
    }
  }

  addTrackToFirebase(AddTrackData addTrackData) {
    firebaseRepository.addTrackToDatabase(addTrackData);
  }
}
