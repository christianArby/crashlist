import 'dart:async';

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rxdart/rxdart.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../player_repository.dart';

part 'player_view_state.dart';

class PlayerViewCubit extends Cubit<PlayerViewState> {
  PlayerViewCubit() : super(PlayerViewInitial());

  StreamSubscription playerStream;

  Future<void> init() async {
    await connectToSpotifyRemote();
    emit(PlayerViewInitial());
    await streamEverySecond();
  }

  Future<void> streamEverySecond() async {
    await connectToSpotifyRemote();
    playerStream = Stream.periodic(new Duration(seconds: 1), (i) => i).listen((event) {
      SpotifySdk.subscribePlayerState().take(1).listen((playerState) {
        emit(PlayerViewLoaded(playerState));
        if (playerState.isPaused) {
          stopStreamUntilStateChange();
        }
      });
    });
  }

  Future<void> stopStreamUntilStateChange() async {
    await connectToSpotifyRemote();
    playerStream.pause();
    // TODO ÄNDRA TAKE 100!
    SpotifySdk.subscribePlayerState().take(100).listen((event) {
      if (!event.isPaused) {
        streamEverySecond();
      }
    });
  }

  Future<void> connectToSpotifyRemote() async {
  try {
    await SpotifySdk.connectToSpotifyRemote(
        clientId: DotEnv().env['CLIENT_ID'].toString(),
        redirectUrl: DotEnv().env['REDIRECT_URL'].toString());
  } on PlatformException {} on MissingPluginException {}}

  void togglePlay(PlayerState playerState) {
    if (playerState.isPaused) {
      resume();
    } else {
      pause();
    }
  }

  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on MissingPluginException {}
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on MissingPluginException {}
  }

  void skipNext() {

  }


  dispose() {
    playerStream.cancel();
  }
}
