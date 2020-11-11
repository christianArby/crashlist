import 'package:crashlist/list/list_cubit.dart';
import 'package:crashlist/playlist/playlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'playlist_minimal.dart';

class ListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Playlists')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final playlistsCubit = context.bloc<ListCubit>();
    playlistsCubit.getPlaylists();
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    return BlocBuilder<ListCubit, ListState>(
      builder: (context, state) {
        if (state is ListInitial) {
          return CircularProgressIndicator();
        } else if (state is ListLoading) {
          return CircularProgressIndicator();
        } else if (state is ListLoaded) {
          return ListView(
            padding: const EdgeInsets.only(top: 20.0),
            children: state.playlists.playlists
                .map((data) => _buildListItem(context, data))
                .toList(),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildListItem(BuildContext context, PlaylistMinimal data) {
    return Padding(
      key: ValueKey(data),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(data.name),
          trailing: Text(data.name),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlaylistScreen(data.playlistId)),
          ),
        ),
      ),
    );
  }
}
