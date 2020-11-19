import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crashlist/player_view/player_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


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
            return _buildList(context, state.playerState.playbackPosition.toString());
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget _buildList(BuildContext context, String playbackPosition) {
    return Text(playbackPosition);
  }
}


