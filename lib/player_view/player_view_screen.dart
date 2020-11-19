import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/player_view/player_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_sdk/models/player_state.dart';


class PlayerViewScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final playerViewCubit = context.bloc<PlayerViewCubit>();
    playerViewCubit.init();

    return BlocBuilder<PlayerViewCubit, PlayerViewState>(
        builder: (context, state) {
          if (state is PlayerViewInitial) {
            return CircularProgressIndicator();
          } else if (state is PlayerViewLoaded) {
            return _buildList(context, state.playerState);
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget _buildList(BuildContext context, PlayerState playerState) {
    final playerViewCubit = context.bloc<PlayerViewCubit>();
    return Column(
      children: [
        Slider(
          value: calculatePosition(playerState),
          onChanged: (value) {
          },
        ),
        Text(playerState.playbackPosition.toString()),
        IconButton(
          icon: new Icon(Icons.play_circle_filled),
          onPressed: () {
            playerViewCubit.togglePlay(playerState);
          },
        ),
        IconButton(
          icon: new Icon(Icons.skip_next),
          onPressed: () {},
        )
      ],
    );
  }

  double calculatePosition(PlayerState playerstate) {
    return playerstate.playbackPosition/playerstate.track.duration;
  }
}

