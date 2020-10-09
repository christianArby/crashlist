import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:crashlist/playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'firebase_bloc.dart';
import 'firebase_bloc_provider.dart';
import 'firebase_playlist.dart';
import 'playlists_screen.dart';

class CrashlistScreen extends StatefulWidget {
  @override
  _CrashlistScreenState createState() {
    return _CrashlistScreenState();
  }
}

class _CrashlistScreenState extends State<CrashlistScreen> {
  bool _firstTimeLoad = true;

  /* List<String> orderArray = [];
  List<String> currentOrderArray = [];
  List<DocumentSnapshot> snapshotPlaylist = [];*/
  FirebasePlaylist firebasePlaylist;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Crashlist')),
      body: _buildBody(context),
    );
  }

  final databaseReference = Firestore.instance;

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
        Function eq = const ListEquality().equals;
        if (!(eq(snapshot.data.firebasePlaylist.orderArray, firebasePlaylist?.orderArray))) {
          firebasePlaylist = snapshot.data.firebasePlaylist;
        }
        return _buildList(context);
      },
    );
  }

  Widget _buildList(BuildContext context) {
    return ReorderableListView(
      onReorder: _updatePlaylistOrder,
      padding: const EdgeInsets.only(top: 20.0),
      children: firebasePlaylist.snapshotPlaylist.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    FirebaseBloc bloc = FirebaseBlocProvider.of(context).bloc;
    final record = Record.fromSnapshot(data);
    return Dismissible(
      key: Key(record.artist),
      onDismissed: (direction) {
        // Remove the item from the data source.
        bloc.removeTrackFromPlaylist(data);
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
            title: Text(record.artist.substring(0, 5)),
            trailing: Text(record.title.substring(0,5)),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlaylistsScreen()),
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
    var movedId = firebasePlaylist.orderArray[oldIndex];

    firebasePlaylist.orderArray.removeAt(oldIndex);
    firebasePlaylist.orderArray.insert(newIndex, movedId);

    Firestore.instance.collection('playlistOrder')
        .document('order')
        .updateData({'currentPlaylist': firebasePlaylist.orderArray})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));

    setState(() {
      DocumentSnapshot movedSnap = firebasePlaylist.snapshotPlaylist[oldIndex];
      firebasePlaylist.snapshotPlaylist.removeAt(oldIndex);
      firebasePlaylist.snapshotPlaylist.insert(newIndex, movedSnap);
    });
  }
}