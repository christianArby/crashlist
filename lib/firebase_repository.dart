
import 'package:cloud_firestore/cloud_firestore.dart';

import 'crashlist/firebase_playlist.dart';
import 'package:rxdart/rxdart.dart';


class FirebaseRepository {
  QuerySnapshot querySnapshot;
  FirebasePlaylist firebasePlaylist;

  // 1
  final _crashlistController = BehaviorSubject<FirebasePlaylist>();
  BehaviorSubject<FirebasePlaylist> get crashlistStream => _crashlistController.stream;



  void init() {

    listenToCrashlist().listen((event) {
      _crashlistController.sink.add(event);
    });
  }

  Stream<FirebasePlaylist> listenToCrashlist () {

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


    return Rx.combineLatest2(orderStream, playlistStream, (a, b) => 
    updatePlaylist(a, b));
  }

  FirebasePlaylist updatePlaylist(
      DocumentSnapshot documentSnapshot, QuerySnapshot querySnapshot) {
    List<String> orderArray = List.from(documentSnapshot.data['orderArray']);
    if (firebasePlaylist == null ||
        !orderArraysEqual(orderArray, firebasePlaylist?.orderArray)) {
      List<DocumentSnapshot> snapshotPlaylist = List();
      for (String orderId in orderArray) {
        snapshotPlaylist.add(querySnapshot.documents
            .firstWhere((element) => element.documentID == orderId));
      }
      firebasePlaylist = FirebasePlaylist(orderArray, snapshotPlaylist);
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

  void dispose() {
    _crashlistController.close();
  }
}
