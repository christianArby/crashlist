import 'dart:async';

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rxdart/rxdart.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

part 'player_view_state.dart';

class PlayerViewCubit extends Cubit<PlayerViewState> {
  PlayerViewCubit() : super(PlayerViewInitial());

  StreamSubscription playerStream;

  void init() async {
    await connectToSpotifyRemote();
    emit(PlayerViewInitial());
    // TODO check if dispose is necessary
    playerStream = Stream.periodic(new Duration(seconds: 1), (i) => i).listen((event) {
      SpotifySdk.subscribePlayerState().take(1).listen((event) {
        emit(PlayerViewLoaded(event));
      });
    });

    SpotifySdk.subscribePlayerState().listen((playerState) {
      if (playerState.isPaused) {
        playerStream.pause();
      } else {
        playerStream.resume();
      }
    });
  }

  Future<void> connectToSpotifyRemote() async {
  try {
    await SpotifySdk.connectToSpotifyRemote(
        clientId: DotEnv().env['CLIENT_ID'].toString(),
        redirectUrl: DotEnv().env['REDIRECT_URL'].toString());
  } on PlatformException {} on MissingPluginException {}}


  dispose() {
    playerStream.cancel();
  }
}
