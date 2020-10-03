import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/firebase_playlist.dart';
import 'package:flutter/cupertino.dart';

class FirebaseAPIClient {

  final databaseReference = Firestore.instance;

  Future<FirebasePlaylist> getCurrentPlaylist(List<String> orderArray) async {
    QuerySnapshot snapshot = await databaseReference
        .collection("playlistTest").getDocuments();

    List<DocumentSnapshot> snapshotPlaylist = List();
    for (String orderId in orderArray) {
      snapshotPlaylist.add(snapshot.documents.firstWhere((element) => element.documentID==orderId));
    }

    FirebasePlaylist firebasePlaylist = FirebasePlaylist(orderArray, snapshotPlaylist);
    return firebasePlaylist;
  }

  Future<List<String>> getOrderArray() async {
    DocumentSnapshot snapshot = await Firestore.instance.collection('playlistOrder').document("order").get();
    List<String> orderArray = List.from(snapshot.data['currentPlaylist']);
    return orderArray;
  }
}