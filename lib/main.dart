import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/MyPlaylists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

import 'SecondRoute.dart';

Future<void> main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crashlist',
      home: FirstRoute(),
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

  Future<MyPlaylists> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  List<String> orderArray = [];
  List<String> currentOrderArray = [];

  List<DocumentSnapshot> snapshotPlaylist = [];



  @override
  Widget build(BuildContext context) {
    getCurrentPlaylistOrder();

    return Scaffold(
      appBar: AppBar(title: Text('Crashlist')),
      body: _buildBody(context),
    );
  }

  final databaseReference = Firestore.instance;

  getCurrentPlaylistOrder() async {
    DocumentSnapshot snapshot = await databaseReference
        .collection("playlistOrder")
        .document("order")
        .get();
    // use this DocumentSnapshot snapshot to get the current data that is there in the document inside of your collection.
    orderArray = List.from(snapshot['currentPlaylist']);
    print(orderArray); // to check whats actually there and if its working...

    Function eq = const ListEquality().equals;
    if (!eq(currentOrderArray, orderArray)) {
      getCurrentPlaylist();
    }
    //lets assume newPostsList is the data that you want to put in this referenced document.
  }

  getCurrentPlaylist() async {
    QuerySnapshot snapshot = await databaseReference
        .collection("playlistTest").getDocuments();
    // use this DocumentSnapshot snapshot to get the current data that is there in the document inside of your collection.
    snapshotPlaylist = List();
    for (String orderId in orderArray) {
      snapshotPlaylist.add(snapshot.documents.firstWhere((element) => element.documentID==orderId));
    }
    print(snapshotPlaylist); // to check whats actually there and if its working...

    Function eq = const ListEquality().equals;
    if (!eq(currentOrderArray, orderArray)) {
      setState(() {
        currentOrderArray = orderArray;
      });
    }
    //lets assume newPostsList is the data that you want to put in this referenced document.
  }

  Widget _buildBody(BuildContext context) {
    return _buildList(context, snapshotPlaylist);
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ReorderableListView(
      onReorder: _updatePlaylistOrder,
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  var dumList = ["hej", "sdsa", "sadasd"];

  Widget _dumList(BuildContext context, List<DocumentSnapshot> snapshot) {



    return ReorderableListView(
      onReorder: onReorder,

      padding: const EdgeInsets.only(top: 20.0),
      children: [
        for (final item in dumList)
          ListTile(
            key: ValueKey(item),
            title: Text(item)
          )
      ],
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    setState(() {
      String game = dumList[oldIndex];

      dumList.removeAt(oldIndex);
      dumList.insert(newIndex, game);
    });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.artist),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.artist),
          trailing: FutureBuilder<MyPlaylists>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.playlistNames.first);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
          onTap: () => {
          print(futureAlbum),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondRoute()),
            )
          } ,
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

/*class SecondRoute extends StatelessWidget {

  final authToken = getAuthenticationToken();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}*/

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

Future<MyPlaylists> fetchAlbum() async {
  final response = await http.get('https://us-central1-crashlist-6a66c.cloudfunctions.net/testSpotify2');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return MyPlaylists.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}



