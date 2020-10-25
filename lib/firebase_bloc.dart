import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/firebase_api_client.dart';
import 'package:crashlist/firebase_playlist.dart';
import 'package:crashlist/playlist.dart';
import 'package:http/http.dart' as http;

class FirebaseBloc {
  final _apiClient = FirebaseAPIClient();

  FirebaseBlocState _currentState;

  StreamSubscription<FirebasePlaylist> _fetchFirebasePlaylistSub;

  List<String> orderArray;
  List<AddTrackData> tracksToBeAddedToSpotify = List.empty(growable: true);
  QuerySnapshot querySnapshot;
  FirebasePlaylist firebasePlaylist;

  final _firebaseController = StreamController<FirebaseBlocState>.broadcast();
  Stream<FirebaseBlocState> get firebaseStream => _firebaseController.stream;

  FirebaseBloc() {
    _currentState = FirebaseBlocState.empty();
  }

  FirebaseBlocState getCurrentState() {
    return _currentState;
  }

  resetQueue() {
    tracksToBeAddedToSpotify = List.empty(growable: true);
  }

  fetchCurrentPlaylist() {
    _fetchFirebasePlaylistSub?.cancel();
    _currentState.loading = true;
    _firebaseController.add(_currentState);

    Stream<DocumentSnapshot> orderStream = Firestore.instance.collection('playlists').document("40znmRYsotw673C5LD4rrz").collection('meta').document('order').snapshots();
    orderStream.listen((event) {
      orderArray = List.from(event.data['orderArray']);
      updatePlaylist();
    });

    Stream<QuerySnapshot> playlistStream = Firestore.instance.collection("playlists").document("40znmRYsotw673C5LD4rrz").collection("tracks").snapshots();
    playlistStream.listen((event) {
      querySnapshot = event;
      updatePlaylist();
    });
  }

  updatePlaylist() {

    if (querySnapshot!=null && orderArray!=null) {

      if (firebasePlaylist==null || !orderArraysEqual(orderArray, firebasePlaylist?.orderArray)) {
        List<DocumentSnapshot> snapshotPlaylist = List();
        for (String orderId in orderArray) {
          snapshotPlaylist.add(querySnapshot.documents.firstWhere((element) => element.documentID==orderId));
        }

        FirebasePlaylist firebasePlaylist = FirebasePlaylist(orderArray, snapshotPlaylist);
        _currentState.loading = false;
        _currentState.firebasePlaylist = firebasePlaylist;
        _firebaseController.add(_currentState);
      } else {
        firebasePlaylist.orderArray = orderArray;
        _currentState.loading = false;
        _currentState.firebasePlaylist = firebasePlaylist;
        _firebaseController.add(_currentState);
      }
    }
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
    },onError: (e) {
    });

  }

  Future<bool> addTrackFuture(AddTrackData addTrackData) async {
    var url ='https://us-central1-crashlist-6a66c.cloudfunctions.net/widgets/addTrackToSpotifyListHttp';

    Map data = addTrackData.spotifyTrack.toJson();
    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: body
    );
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


    Firestore.instance.collection('playlists').document("40znmRYsotw673C5LD4rrz").collection('meta').document('order')
        .updateData({'orderArray': FieldValue.arrayRemove([spotifyTrack.reference.documentID])})
        .then((value) => print("Track deleted"))
        .catchError((error) => print("Failed to delete track: $error"));

    Firestore.instance.collection('playlists').document('40znmRYsotw673C5LD4rrz').collection('tracks').document(spotifyTrack.reference.documentID).delete()
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

class FirebaseBlocState {
  bool loading;
  FirebasePlaylist firebasePlaylist;

  FirebaseBlocState(this.loading, this.firebasePlaylist);

  FirebaseBlocState.empty() {
    loading = false;
    firebasePlaylist = null;
  }
}