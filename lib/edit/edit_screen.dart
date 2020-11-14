import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:crashlist/crashlist/crashlist_cubit.dart';
import 'package:crashlist/crashlist/crashlist_screen.dart';
import 'package:crashlist/crashlist/firebase_playlist.dart';
import 'package:crashlist/edit/edit_cubit.dart';
import 'package:crashlist/playlist/playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditScreen extends StatefulWidget {
  @override
  _EditScreenState createState() {
    return _EditScreenState();
  }
}

class _EditScreenState extends State<EditScreen> {
  bool _firstTimeLoad = true;
  FirebasePlaylist firebasePlaylist;

  @override
  Widget build(BuildContext context) {
    final editCubit = context.bloc<EditCubit>();

    return Scaffold(
        appBar: AppBar(
          title: Text('Edit'),
          leading: IconButton(
            icon: Icon(Icons.save),
            onPressed: () => editCubit.saveEdit(firebasePlaylist),
          ),
        ),
        body: _buildBody(context));
  }

  final databaseReference = Firestore.instance;

  Widget _buildBody(BuildContext context) {
    final crashListCubit = context.bloc<CrashlistCubit>();
    if (_firstTimeLoad) {
      final editCubit = context.bloc<EditCubit>();
      editCubit.updateEdit();
      _firstTimeLoad = false;
    }

    return BlocConsumer<EditCubit, EditState>(
      
      listener: (context, state) {
      if (state is EditSaved) {
        Navigator.pop(context);
        crashListCubit.updateCrashlist();
      }
    }, builder: (context, state) {
      if (state is EditInitial) {
        return CircularProgressIndicator();
      } else if (state is EditLoading) {
        return CircularProgressIndicator();
      } else if (state is EditLoaded) {
        Function eq = const ListEquality().equals;
        if (!(eq(
            state.firebasePlaylist.orderArray, firebasePlaylist?.orderArray))) {
          firebasePlaylist = state.firebasePlaylist;
        }
        return _buildList(context);
      } else {
        return CircularProgressIndicator();
      }
    });
  }

  Widget _buildList(BuildContext context) {
    return ReorderableListView(
      onReorder: _updatePlaylistOrder,
      padding: const EdgeInsets.only(top: 20.0),
      children: firebasePlaylist.snapshotPlaylist
          .map((data) => _buildListItem(context, data))
          .toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    //EditBloc bloc = FirebaseBlocProvider.of(context).bloc;
    final spotifyTrack = SpotifyTrack.fromSnapshot(data);
    return Dismissible(
      key: Key(spotifyTrack.name),
      onDismissed: (direction) {
        firebasePlaylist.orderArray.remove(data.documentID);
        firebasePlaylist.snapshotPlaylist.remove(data);
      },
      child: Padding(
        key: ValueKey(spotifyTrack.name),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
              title: Text(spotifyTrack.name.substring(0, 2)),
              trailing: Text(spotifyTrack.name.substring(0, 2))),
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

    setState(() {
      DocumentSnapshot movedSnap = firebasePlaylist.snapshotPlaylist[oldIndex];
      firebasePlaylist.snapshotPlaylist.removeAt(oldIndex);
      firebasePlaylist.snapshotPlaylist.insert(newIndex, movedSnap);
    });
  }
}
