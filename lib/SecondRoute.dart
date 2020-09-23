import 'dart:convert';

import 'package:flutter/material.dart';

import 'MyPlaylists.dart';
import 'package:http/http.dart' as http;

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyPlaylistsPage();
  }
}

class MyPlaylistsPage extends StatefulWidget {
  @override
  _MyPlaylistsPage createState() {
    return _MyPlaylistsPage();
  }
}

class _MyPlaylistsPage extends State<MyPlaylistsPage> {

  Future<MyPlaylists> futureMyPlaylists;

  @override
  void initState() {
    super.initState();
    futureMyPlaylists = fetchMyPlaylists();
  }

  var testList = ["hej", "då", "se"];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('My Playlists')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    return FutureBuilder<MyPlaylists>(
      future: futureMyPlaylists,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            padding: const EdgeInsets.only(top: 20.0),
            children: snapshot.data.playlistNames.map((data) => _buildListItem(context, data)).toList(),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }

  Widget _buildListItem(BuildContext context, String data) {

    return Padding(
      key: ValueKey(data),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(data),
          trailing: Text(data),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SecondRoute()),
          ),
        ),
      ),
    );
  }
}

Future<MyPlaylists> fetchMyPlaylists() async {
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