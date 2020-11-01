import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePlaylist {
  List<String> orderArray = [];
  List<DocumentSnapshot> snapshotPlaylist = [];
  FirebasePlaylist(this.orderArray, this.snapshotPlaylist);
}