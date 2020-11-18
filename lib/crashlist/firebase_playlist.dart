import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/playlist/playlist.dart';

class FirebasePlaylist {
  List<String> orderArray = [];
  List<SpotifyTrack> crashlist = [];
  FirebasePlaylist(this.orderArray, this.crashlist);
}