/* import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/firebase_api_client.dart';
import 'package:crashlist/firebase_playlist.dart';
import 'package:crashlist/playlist.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';

class CrashlistBloc extends Bloc<dynamic, dynamic> {
  CrashlistBlocState _currentState;

  StreamSubscription<FirebasePlaylist> _fetchFirebasePlaylistSub;

  List<String> orderArray;
  List<AddTrackData> tracksToBeAddedToSpotify = List.empty(growable: true);
  QuerySnapshot querySnapshot;
  FirebasePlaylist firebasePlaylist;

  final _crashlistController = StreamController<CrashlistBlocState>();
  Stream<CrashlistBlocState> get firebaseStream => _crashlistController.stream;

  CrashlistBloc() {
    _currentState = CrashlistBlocState.empty();
  }

  CrashlistBlocState getCurrentState() {
    return _currentState;
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
    addTrackFuture(addTrackData).then((bool success) {
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

  Future<bool> addTrackFuture(AddTrackData addTrackData) async {
    var url =
        'https://us-central1-crashlist-6a66c.cloudfunctions.net/widgets/addTrackToSpotifyListHttp';

    Map data = addTrackData.spotifyTrack.toJson();
    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    print("${response.statusCode}");
    print("${response.body}");
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return true;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return false;
      throw Exception('Failed to load album');
    }
  }

  removeTrackFromPlaylist(DocumentSnapshot snapshot) {
    var spotifyTrack = SpotifyTrack.fromSnapshot(snapshot);

    Firestore.instance
        .collection('playlists')
        .document("40znmRYsotw673C5LD4rrz")
        .collection('meta')
        .document('order')
        .updateData({
          'orderArray':
              FieldValue.arrayRemove([spotifyTrack.reference.documentID])
        })
        .then((value) => print("Track deleted"))
        .catchError((error) => print("Failed to delete track: $error"));

    Firestore.instance
        .collection('playlists')
        .document('40znmRYsotw673C5LD4rrz')
        .collection('tracks')
        .document(spotifyTrack.reference.documentID)
        .delete()
        .then((value) => print("Track deleted"))
        .catchError((error) => print("Failed to delete track: $error"));
  }

  bool orderArraysEqual(List<String> oArray1, List<String> oArray2) {
    var equal = true;
    for (var id in oArray1) {
      if (!oArray2.contains(id)) {
        equal = false;
      }
    }
    for (var id in oArray2) {
      if (!oArray1.contains(id)) {
        equal = false;
      }
    }
    return equal;
  }
}

class AddTrackData {
  String playlistId;
  SpotifyTrack spotifyTrack;

  AddTrackData(this.playlistId, this.spotifyTrack);
}

class CrashlistBlocState {
  bool loading;
  FirebasePlaylist firebasePlaylist;

  CrashlistBlocState(this.loading, this.firebasePlaylist);

  CrashlistBlocState.empty() {
    loading = false;
    firebasePlaylist = null;
  }
} */