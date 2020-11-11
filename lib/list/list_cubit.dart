import 'package:bloc/bloc.dart';
import 'package:crashlist/spotify_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'playlists.dart';

part 'list_state.dart';

class ListCubit extends Cubit<ListState> {
  final SpotifyRepository spotifyRepository;
  ListCubit(this.spotifyRepository) : super(ListInitial());

  Future<void> getPlaylists() async {
    try {
      emit(ListLoading());
      final playlists = await spotifyRepository.fetchMyPlaylists();
      emit(ListLoaded(playlists));
    } on Exception {
      emit(ListError('Could not load playlists. Is the device online?'));
    }
  }
}




