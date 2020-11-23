import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/crashlist_colors.dart';
import 'package:crashlist/player_view/player_view_cubit.dart';
import 'package:flutter/cupertino.dart';
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

    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Text("1:12"),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        trackHeight: 1,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
                        activeTrackColor: CrashlistColors.spotifyGreen,
                        thumbColor: CrashlistColors.spotifyGreen,
                        inactiveTrackColor: Colors.grey
                    ),
                    child: Slider(
                      value: calculatePosition(playerState),
                      onChanged: (value) {
                      },
                    ),
                  ),
                ),
                Text("3:22")
              ],

            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        playerState.track.artist.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(playerState.track.name),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: new Icon(Icons.play_circle_filled, color: CrashlistColors.spotifyGreen,),
                      onPressed: () {
                        playerViewCubit.togglePlay(playerState);
                      },
                    ),
                    IconButton(
                      iconSize: 48,
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      icon: new Icon(Icons.skip_next, color: CrashlistColors.spotifyGreen,),
                      onPressed: () {
                        playerViewCubit.skipNext();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double calculatePosition(PlayerState playerstate) {
    return playerstate.playbackPosition/playerstate.track.duration;
  }
}


