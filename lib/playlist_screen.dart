import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_sdk/spotify_sdk.dart';

class PlaylistScreen extends StatefulWidget {

  final String playlistId;
  PlaylistScreen(this.playlistId);


  @override
  _PlaylistScreenState createState() {
    return _PlaylistScreenState(playlistId);
  }
}

class _PlaylistScreenState extends State<PlaylistScreen> {

  final String playlistId;

  _PlaylistScreenState(this.playlistId);

  Future<List<SpotifyTrack>> futureTracks;

  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    getAuthenticationToken().then((String value) {
      setState(() {
        futureTracks = fetchMySinglePlaylist(value, playlistId);
      });
    },
        onError: (e) {

        });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('My Single Playlist')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    return FutureBuilder<List<SpotifyTrack>>(
      future: futureTracks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            padding: const EdgeInsets.only(top: 20.0),
            children: snapshot.data.map((data) => _buildListItem(context, data)).toList(),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }

  Widget _buildListItem(BuildContext context, SpotifyTrack data) {

    return Padding(
      key: ValueKey(data),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: CheckboxListTile(
          title: Text(data.name),
          value: _isChecked,
          onChanged: (bool value) {
            saveTrackToDatabase(data.trackId, data.name);
            setState(() {
              _isChecked = value;
            });
          },
        ),
      ),
    );
  }

  void saveTrackToDatabase(String trackId, String trackName) {
    Firestore.instance.collection('playlistTest').document(trackId).setData({
      'artist': trackName,
      'title': trackName
    }).then((value) => print("Track Updated")).catchError((error) => print("Failed to update track: $error"));

    Firestore.instance.collection('playlistOrder').document('order')
        .updateData({'currentPlaylist': FieldValue.arrayUnion([trackId])})
        .then((value) => print("Track Updated"))
        .catchError((error) => print("Failed to update track: $error"));


  }
}

Future<List<SpotifyTrack>> fetchMySinglePlaylist(String authToken, String playlistId) async {

  var queryParameters = {
    'authToken': authToken.toString(),
    'playlistId': playlistId,
  };

  var uri =
  Uri.https('us-central1-crashlist-6a66c.cloudfunctions.net', '/tracks', queryParameters);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<SpotifyTrack> list = List();
    list = (json.decode(response.body) as List)
        .map((data) => new SpotifyTrack.fromJson(data))
        .toList();
    return list;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
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
