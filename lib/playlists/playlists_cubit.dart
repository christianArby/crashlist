import 'package:bloc/bloc.dart';
import 'package:crashlist/spotify_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'playlists.dart';

part 'playlists_state.dart';

class PlaylistsCubit extends Cubit<PlaylistsState> {
  final SpotifyRepository spotifyRepository;
  PlaylistsCubit(this.spotifyRepository) : super(PlaylistsInitial());

  Future<void> getPlaylists() async {
    try {
      emit(PlaylistsLoading());
      final playlists = await spotifyRepository.fetchMyPlaylists();
      emit(PlaylistsLoaded(playlists));
    } on Exception {
      emit(PlaylistsError('Could not load playlists. Is the device online?'));
    }
  }
}




