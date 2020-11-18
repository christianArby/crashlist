import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:crashlist/crashlist/crashlist_cubit.dart';
import 'package:crashlist/crashlist/firebase_playlist.dart';
import 'package:crashlist/playlist/playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class CrashlistScreen extends StatefulWidget {
  @override
  _CrashlistScreenState createState() {
    return _CrashlistScreenState();
  }
}

class _CrashlistScreenState extends State<CrashlistScreen> {
  bool _firstTimeLoad = true;
  FirebasePlaylist firebasePlaylist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Crashlist'),
        ),
        body: _buildBody(context));
  }

  final databaseReference = Firestore.instance;

  Widget _buildBody(BuildContext context) {
    connectToSpotifyRemote();
    final crashListCubit = context.bloc<CrashlistCubit>();
    if (_firstTimeLoad) {
      crashListCubit.updateCrashlist();
      _firstTimeLoad = false;
    }

    return BlocBuilder<CrashlistCubit, CrashlistState>(
        builder: (context, state) {
      if (state is CrashlistInitial) {
        return CircularProgressIndicator();
      } else if (state is CrashlistLoading) {
        return CircularProgressIndicator();
      } else if (state is CrashlistLoaded) {
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
    final crashlistCubit = context.bloc<CrashlistCubit>();
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {
        _updatePlaylistOrder(oldIndex, newIndex);
        crashlistCubit.setOrder(firebasePlaylist.orderArray);
      },
      padding: const EdgeInsets.only(top: 20.0),
      children: firebasePlaylist.crashlist
          .map((spotifyTrack) => _buildListItem(context, spotifyTrack))
          .toList(),
    );
  }

  Widget _buildListItem(BuildContext context, SpotifyTrack spotifyTrack) {
    final crashlistCubit = context.bloc<CrashlistCubit>();
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        setState(() {
          firebasePlaylist.orderArray.remove(spotifyTrack.uri);
          firebasePlaylist.crashlist.remove(spotifyTrack);
          crashlistCubit.dismissed(firebasePlaylist.orderArray);
        });
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
              trailing: Text(spotifyTrack.name.substring(0, 2)),
              onTap: () => {crashlistCubit.play(spotifyTrack.uri)})
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
      SpotifyTrack movedSnap = firebasePlaylist.crashlist[oldIndex];
      firebasePlaylist.crashlist.removeAt(oldIndex);
      firebasePlaylist.crashlist.insert(newIndex, movedSnap);
    });
  }

  Future<void> connectToSpotifyRemote() async {
  try {
    await SpotifySdk.connectToSpotifyRemote(
        clientId: DotEnv().env['CLIENT_ID'].toString(),
        redirectUrl: DotEnv().env['REDIRECT_URL'].toString());
  } on PlatformException {} on MissingPluginException {}
}
}


