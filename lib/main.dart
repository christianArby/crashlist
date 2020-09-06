import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crashlist',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {

  List<String> orderArray = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crashlist')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('playlistOrder').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        orderArray = List.from(snapshot.data.documents.first['currentPlaylist']);

        return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('playlistTest').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            List<DocumentSnapshot> snapshotPlaylist = [];
            for (String orderId in orderArray) {
              snapshotPlaylist.add(snapshot.data.documents.firstWhere((element) => element.documentID==orderId));
            }
            return _buildList(context, snapshotPlaylist);
          },
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        _updatePlaylistOrder(oldIndex, newIndex);
      },

      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
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
          trailing: Text(record.title),
          onTap: () => print(record),
        ),
      ),
    );
  }

  void _updatePlaylistOrder(int oldIndex, int newIndex) {
    var movedId = orderArray[oldIndex];
    if (newIndex>orderArray.length-1) {
      orderArray.removeAt(oldIndex);
      print(orderArray);
      orderArray.add(movedId);
      print(orderArray);
    } else {
      orderArray.removeAt(oldIndex);
      print(orderArray);
      orderArray.insert(newIndex, movedId);
      print(orderArray);
    }

    Firestore.instance.collection('playlistOrder')
        .document('order')
        .updateData({'currentPlaylist': orderArray})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));;
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