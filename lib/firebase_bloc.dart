import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/firebase_api_client.dart';
import 'package:crashlist/firebase_playlist.dart';
import 'package:crashlist/playlist.dart';

class FirebaseBloc {
  final _apiClient = FirebaseAPIClient();

  FirebaseBlocState _currentState;

  StreamSubscription<FirebasePlaylist> _fetchFirebasePlaylistSub;

  List<String> orderArray;
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

  fetchCurrentPlaylist() {
    _fetchFirebasePlaylistSub?.cancel();

    _currentState.loading = true;
    _firebaseController.add(_currentState);

    Stream<DocumentSnapshot> orderStream = Firestore.instance.collection('playlistOrder').document("order").snapshots();
    orderStream.listen((event) {
      orderArray = List.from(event.data['currentPlaylist']);
      updatePlaylist();
    });

    Stream<QuerySnapshot> playlistStream = Firestore.instance.collection("playlistTest").snapshots();
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

  removeTrackFromPlaylist(DocumentSnapshot snapshot) {
    var spotifyTrack = SpotifyTrack.fromSnapshot(snapshot);


    Firestore.instance.collection('playlistOrder').document('order')
        .updateData({'currentPlaylist': FieldValue.arrayRemove([spotifyTrack.reference.documentID])})
        .then((value) => print("Track deleted"))
        .catchError((error) => print("Failed to delete track: $error"));

    Firestore.instance.collection('playlistTest').document(spotifyTrack.reference.documentID).delete()
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

class FirebaseBlocState {
  bool loading;
  FirebasePlaylist firebasePlaylist;

  FirebaseBlocState(this.loading, this.firebasePlaylist);

  FirebaseBlocState.empty() {
    loading = false;
    firebasePlaylist = null;
  }
}