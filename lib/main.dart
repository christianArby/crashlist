import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/firebase_bloc_provider.dart';
import 'package:crashlist/firebase_playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

import 'firebase_bloc.dart';
import 'second_route.dart';

Future<void> main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final bloc = FirebaseBloc();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crashlist',
      home: FirebaseBlocProvider(
        bloc: bloc,
        child: FirstRoute(),
      ),
    );
  }
}

class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  bool _firstTimeLoad = true;

  List<String> orderArray = [];
  List<String> currentOrderArray = [];
  List<DocumentSnapshot> snapshotPlaylist = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Crashlist')),
      body: _buildBody(context),
    );
  }

  final databaseReference = Firestore.instance;

  removeTrackFromPlaylist(DocumentSnapshot snapshot) {
    var record = Record.fromSnapshot(snapshot);
    orderArray.remove(record.reference.documentID);
    currentOrderArray.remove(record.reference.documentID);
    snapshotPlaylist.remove(snapshot);


    Firestore.instance.collection('playlistOrder').document('order')
        .updateData({'currentPlaylist': FieldValue.arrayRemove([record.reference.documentID])})
        .then((value) => print("Track deleted"))
        .catchError((error) => print("Failed to delete track: $error"));

    Firestore.instance.collection('playlistTest').document(record.reference.documentID).delete()
        .then((value) => print("Track deleted"))
        .catchError((error) => print("Failed to delete track: $error"));

  }

  /*getCurrentPlaylistOrder(DocumentSnapshot snapshot) async {
    // use this DocumentSnapshot snapshot to get the current data that is there in the document inside of your collection.
    orderArray = List.from(snapshot['currentPlaylist']);
    print(orderArray); // to check whats actually there and if its working...

    Function eq = const ListEquality().equals;
    if (!eq(currentOrderArray, orderArray) || orderArray.length!=snapshotPlaylist.length) {
      getCurrentPlaylist();
    }
    //lets assume newPostsList is the data that you want to put in this referenced document.

    //TODO Streambuilder som en widget så att allt uppdateras hela tiden
  }

  getCurrentPlaylist() async {
    Function eq = const ListEquality().equals;
    if (!eq(currentOrderArray, orderArray) || orderArray.length!=snapshotPlaylist.length) {
    QuerySnapshot snapshot = await databaseReference
        .collection("playlistTest").getDocuments();
    // use this DocumentSnapshot snapshot to get the current data that is there in the document inside of your collection.
    snapshotPlaylist = List();
    for (String orderId in orderArray) {
      snapshotPlaylist.add(snapshot.documents.firstWhere((element) => element.documentID==orderId));
    }
    print(snapshotPlaylist); // to check whats actually there and if its working...

      setState(() {
        currentOrderArray = orderArray;
      });
    }
    //lets assume newPostsList is the data that you want to put in this referenced document.
  }*/

  Widget _buildBody(BuildContext context) {
    FirebaseBloc bloc = FirebaseBlocProvider.of(context).bloc;

    if (_firstTimeLoad) {
      bloc.fetchCurrentPlaylist();
      _firstTimeLoad = false;
    }


    return StreamBuilder<FirebaseBlocState>(


      initialData: bloc.getCurrentState(),
      stream: bloc.firebaseStream,
      builder: (BuildContext context, AsyncSnapshot<FirebaseBlocState> snapshot) {
        if (snapshot.data.loading) return new Text('Loading...');
        return _buildList(context, snapshot.data.firebasePlaylist);
      },
    );
  }

  Widget _buildList(BuildContext context, FirebasePlaylist firebasePlaylist) {
    return ReorderableListView(
      onReorder: _updatePlaylistOrder,
      padding: const EdgeInsets.only(top: 20.0),
      children: firebasePlaylist.snapshotPlaylist.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    return Dismissible(
      key: Key(record.artist),
      onDismissed: (direction) {
        // Remove the item from the data source.
        removeTrackFromPlaylist(data);
      },
      child: Padding(
        key: ValueKey(record.artist),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(record.artist),
            trailing: Text(record.title),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecondRoute()),
              )
            },
          ),
        ),
      ),
    );
  }

  void _updatePlaylistOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    var movedId = orderArray[oldIndex];

    orderArray.removeAt(oldIndex);
    orderArray.insert(newIndex, movedId);

    currentOrderArray = orderArray;

    Firestore.instance.collection('playlistOrder')
        .document('order')
        .updateData({'currentPlaylist': orderArray})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));

    setState(() {
      DocumentSnapshot movedSnap = snapshotPlaylist[oldIndex];

      snapshotPlaylist.removeAt(oldIndex);
      snapshotPlaylist.insert(newIndex, movedSnap);
    });
  }
}


class Record {
  final String artist;
  final String title;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['artist'] != null),
        assert(map['title'] != null),
        artist = map['artist'],
        title = map['title'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$artist:$title>";
}

Future<void> connectToSpotifyRemote() async {
  try {
    var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: DotEnv().env['CLIENT_ID'].toString(),
        redirectUrl: DotEnv().env['REDIRECT_URL'].toString());
  } on PlatformException catch (e) {
  } on MissingPluginException {
  }
}

Future<String> getAuthenticationToken() async {
  try {
    var authenticationToken = await SpotifySdk.getAuthenticationToken(
        clientId: DotEnv().env['CLIENT_ID'].toString(),
        redirectUrl: DotEnv().env['REDIRECT_URL'].toString(),
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing');
    return authenticationToken;
  } on PlatformException catch (e) {
    return Future.error('$e.code: $e.message');
  } on MissingPluginException {
    return Future.error('not implemented');
  }
}



