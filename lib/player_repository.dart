import 'dart:async';
import 'dart:io';

import 'package:crashlist/firebase_repository.dart';
import 'package:crashlist/spotify_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';


class PlayerRepository {
  final FirebaseRepository firebaseRepository;
  final SpotifyRepository spotifyRepository;
  Timer timer;
  PlayerRepository(this.firebaseRepository, this.spotifyRepository);

  void play(String playUri) {
    var firebasePlaylist = firebaseRepository.firebasePlaylist;

    List<String> newOrderArray = List.empty(growable: true);
    bool add = false;

    for (String orderUri in firebasePlaylist.orderArray) {
      if (orderUri == playUri) {
        add = true;
      }
      if (add) {
        newOrderArray.add(orderUri);
      }
    }
    firebaseRepository.updateOrder(newOrderArray);

    playThis(playUri).then((value) => {
          queueThis('spotify:track:3SdYdbx4wbuQmN359DQncQ')
              .then((value) => skipUntilDone(playUri))
        });

    //spotifyRepository.clearAndPlay(playUri);
  }

  Future<void> skipUntilDone(String playUri) async {
    var played = false;
    void pleasePlay() {
      if (!played) {
        SpotifySdk.play(spotifyUri: playUri);
      }
    }
    var keepSkipping = true;
    SpotifySdk.subscribePlayerState().listen((event) {
      if (event.track.uri=='spotify:track:3SdYdbx4wbuQmN359DQncQ') {
        keepSkipping = false;
        pleasePlay();
      }
    });
    var n = 0;
    
    void startSkipping() async {
      n++;
      if (keepSkipping && n<11) {
        sleep(Duration(milliseconds: 100));
        SpotifySdk.trySkipNext();
        startSkipping();
      } else {
        pleasePlay();
      }
    }
    startSkipping();    
  }

  Future<void> playThis(String spotifyTrackUri) async {
    try {
      await SpotifySdk.play(spotifyUri: spotifyTrackUri);
    } on MissingPluginException {}
  }

  Future<void> queueThis(String spotifyTrackUri) async {
    try {
      await SpotifySdk.queue(spotifyUri: spotifyTrackUri);
    } on MissingPluginException {}
  }

  Future<void> connectToSpotifyRemote() async {
    try {
      await SpotifySdk.connectToSpotifyRemote(
          clientId: DotEnv().env['CLIENT_ID'].toString(),
          redirectUrl: DotEnv().env['REDIRECT_URL'].toString());
    } on PlatformException {} on MissingPluginException {}}
}
