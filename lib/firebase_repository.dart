import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/playlist/playlist.dart';
import 'package:crashlist/spotify_repository.dart';

import 'crashlist/firebase_playlist.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseRepository {
  QuerySnapshot querySnapshot;
  FirebasePlaylist firebasePlaylist;

  // 1
  final _crashlistController = BehaviorSubject<FirebasePlaylist>();
  BehaviorSubject<FirebasePlaylist> get crashlistStream =>
      _crashlistController.stream;

  void init() {
    listenToCrashlist().listen((event) {
      firebasePlaylist = event;
      _crashlistController.sink.add(event);
    });
  }

  Stream<FirebasePlaylist> listenToCrashlist() {
    Stream<DocumentSnapshot> orderStream = Firestore.instance
        .collection('playlists')
        .document("40znmRYsotw673C5LD4rrz")
        .collection('meta')
        .document('order')
        .snapshots();

    Stream<QuerySnapshot> playlistStream = Firestore.instance
        .collection("playlists")
        .document("40znmRYsotw673C5LD4rrz")
        .collection("tracks")
        .snapshots();

    return Rx.combineLatest2(
        orderStream, playlistStream, (a, b) => updatePlaylist(a, b));
  }

  FirebasePlaylist updatePlaylist(
      DocumentSnapshot documentSnapshot, QuerySnapshot querySnapshot) {
    List<String> orderArray = List.from(documentSnapshot.data['orderArray']);
    if (firebasePlaylist == null ||
        !orderArraysEqual(orderArray, firebasePlaylist?.orderArray)) {
      List<SpotifyTrack> crashlist = List();
      for (String orderId in orderArray) {
        crashlist.add(SpotifyTrack.fromSnapshot(querySnapshot.documents
            .firstWhere((element) => element.documentID == orderId)));
      }
      firebasePlaylist = FirebasePlaylist(orderArray, crashlist);
    } else {
      firebasePlaylist.orderArray = orderArray;
    }
    return firebasePlaylist;
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

  CollectionReference playlists = Firestore.instance.collection('playlists');

  Future<void> updateOrder(List<String> orderArray) {
    return playlists
        .document('40znmRYsotw673C5LD4rrz')
        .collection('meta')
        .document('order')
        .setData({'orderArray': orderArray})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> addTrackToDatabase (AddTrackData addTrackData) {
    return _addTrack(addTrackData).then((value) => _addOrder(addTrackData));
  }

  Future<void> _addTrack (AddTrackData addTrackData) {
    return Firestore.instance
    .collection('playlists')
    .document(addTrackData.playlistId)
    .collection('tracks')
    .document(addTrackData.spotifyTrack.uri)
    .setData(addTrackData.spotifyTrack.toJson())
    .then((value) => print("Track Updated")).catchError((error) => print("Failed to update track: $error"));
  }

  Future<void> _addOrder (AddTrackData addTrackData) {
    return Firestore.instance
    .collection('playlists')
    .document(addTrackData.playlistId)
    .collection('meta')
    .document('order')
    .updateData({'orderArray': FieldValue.arrayUnion([addTrackData.spotifyTrack.uri])})
    .then((value) => print("Track Updated")).catchError((error) => print("Failed to update track: $error"));
  }

  void dispose() {
    _crashlistController.close();
  }
}
