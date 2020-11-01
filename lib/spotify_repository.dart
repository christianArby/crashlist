import 'dart:convert';
import 'package:crashlist/playlists/playlist_minimal.dart';
import 'package:crashlist/playlists/playlists.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;

class SpotifyRepository {

  Future<Playlists> fetchMyPlaylists() {
    return getAuthenticationToken().then((authToken) {
      return fetchMyPlaylistsFuture(authToken).then((List<PlaylistMinimal> playlists) {
        return Playlists(playlists);
      });
    }, onError: (e) {
      throw Exception('Failed to load playlists');
    });

  }

  Future<List<PlaylistMinimal>> fetchMyPlaylistsFuture(String authToken) async {

    var queryParameters = {
      'authToken': authToken.toString(),
      'param2': 'two',
    };

    var uri =
    Uri.https('us-central1-crashlist-6a66c.cloudfunctions.net', '/myPlaylists', queryParameters);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<PlaylistMinimal> list = List();
      list = (json.decode(response.body) as List)
          .map((data) => new PlaylistMinimal.fromJson(data))
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

}