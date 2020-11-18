import 'package:crashlist/playlist/playlist.dart';
import 'package:crashlist/playlist/playlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../spotify_repository.dart';

class PlaylistScreen extends StatelessWidget {
  
  final String playlistId;
  PlaylistScreen(this.playlistId);

  @override
  Widget build(BuildContext context) {
    final playlistCubit = context.bloc<PlaylistCubit>();
    playlistCubit.getPlaylist(playlistId);

    return Scaffold(
      appBar: AppBar(title: Text('My Single Playlist')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {

    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        if (state is PlaylistInitial) {
          return CircularProgressIndicator();
        } else if (state is PlaylistLoading) {
          return CircularProgressIndicator();
        } else if (state is PlaylistLoaded) {
          return ListView(
            padding: const EdgeInsets.only(top: 20.0),
            children: state.playlistData.spotifyTracks.map((data) => 
            _buildListItem(context, data, state.playlistData.tempAuth)).toList(),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildListItem(BuildContext context, SpotifyTrack spotifyTrack, String tempAuth) {

    final playlistCubit = context.bloc<PlaylistCubit>();

    //CrashlistBloc bloc = FirebaseBlocProvider.of(context).bloc;

    return Padding(
      key: ValueKey(spotifyTrack),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: CheckboxListTile(
          title: Text(spotifyTrack.name),
          value: true,
          onChanged: (bool value) {
            playlistCubit.addTrackToFirebase(AddTrackData('40znmRYsotw673C5LD4rrz', spotifyTrack));
          },
        ),
      ),
    );
  }
}
