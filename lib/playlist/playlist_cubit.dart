import 'package:bloc/bloc.dart';
import 'package:crashlist/playlist/playlist.dart';
import 'package:equatable/equatable.dart';

import '../spotify_repository.dart';

part 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
 final SpotifyRepository spotifyRepository;

  PlaylistCubit(this.spotifyRepository) : super(PlaylistInitial());

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


  resetQueue() {
    tracksToBeAddedToSpotify = List.empty(growable: true);
  }

  addTrackToQueue(AddTrackData addTrackData) {
    if (tracksToBeAddedToSpotify.isEmpty) {
      tracksToBeAddedToSpotify.add(addTrackData);
      addTrackToSpotify(addTrackData);
    } else {
      tracksToBeAddedToSpotify.add(addTrackData);
    }
  }

  addTrackToSpotify(AddTrackData addTrackData) {
    spotifyRepository.addTrackFuture(addTrackData).then((bool success) {
      if (success) {
        print("Wohoo");
        tracksToBeAddedToSpotify.remove(addTrackData);
        if (tracksToBeAddedToSpotify.isNotEmpty) {
          addTrackToSpotify(tracksToBeAddedToSpotify.first);
        }
      } else {
        print("Bohoo");
      }
    }, onError: (e) {});
  }
}
