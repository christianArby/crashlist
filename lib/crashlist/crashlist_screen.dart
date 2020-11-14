import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:crashlist/crashlist/crashlist_cubit.dart';
import 'package:crashlist/edit/edit_screen.dart';
import 'package:crashlist/playlist/playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'firebase_playlist.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CrashlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crashlist'),
        leading: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditScreen()),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  final databaseReference = Firestore.instance;

  Widget _buildBody(BuildContext context) {
    connectToSpotifyRemote();
    final crashlistCubit = context.bloc<CrashlistCubit>();
    crashlistCubit.updateCrashlist();

    return BlocBuilder<CrashlistCubit, CrashlistState>(
        builder: (context, state) {
      if (state is CrashlistInitial) {
        return CircularProgressIndicator();
      } else if (state is CrashlistLoading) {
        return CircularProgressIndicator();
      } else if (state is CrashlistLoaded) {
        return _buildList(context, state.firebasePlaylist);
      } else {
        return CircularProgressIndicator();
      }
    });
  }

  Widget _buildList(BuildContext context, FirebasePlaylist firebasePlaylist) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: firebasePlaylist.snapshotPlaylist
          .map((data) => _buildListItem(context, data))
          .toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    //CrashlistBloc bloc = FirebaseBlocProvider.of(context).bloc;
    final spotifyTrack = SpotifyTrack.fromSnapshot(data);
    return Padding(
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
            onTap: () => {play(spotifyTrack.uri)},
          ),
        ),
      );
  }

  Future<void> play(String spotifyTrackUri) async {
    try {
      await SpotifySdk.play(spotifyUri: spotifyTrackUri);
    } on MissingPluginException {}
  }
}

Future<void> connectToSpotifyRemote() async {
  try {
    await SpotifySdk.connectToSpotifyRemote(
        clientId: DotEnv().env['CLIENT_ID'].toString(),
        redirectUrl: DotEnv().env['REDIRECT_URL'].toString());
  } on PlatformException {} on MissingPluginException {}
}
