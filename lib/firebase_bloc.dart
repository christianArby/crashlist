import 'dart:async';

import 'package:crashlist/firebase_api_client.dart';
import 'package:crashlist/firebase_playlist.dart';

class FirebaseBloc {
  final _apiClient = FirebaseAPIClient();

  FirebaseBlocState _currentState;

  StreamSubscription<FirebasePlaylist> _fetchFirebasePlaylistSub;

  final _firebaseController = StreamController<FirebaseBlocState>.broadcast();
  Stream<FirebaseBlocState> get firebaseStream => _firebaseController.stream;

  FirebaseBloc() {
    _currentState = FirebaseBlocState.empty();
  }

  FirebaseBlocState getCurrentState() {
    return _currentState;
  }

  fetchCurrentPlaylist() {
    _fetchFirebasePlaylistSub?.cancel();

    _currentState.loading = true;
    _firebaseController.add(_currentState);

    _apiClient.getOrderArray().asStream().listen((dynamic orderArray) {
      if (orderArray is List<String>) {

        // TODO lyft ut den nedanför utanför bör kunna använda nersparad orderarray och dessa både triggas hela tiden då de är lyssnare

        _apiClient.getCurrentPlaylist(orderArray).asStream().listen((dynamic firebasePlaylist) {

          if (firebasePlaylist is FirebasePlaylist) {
            _currentState.firebasePlaylist = firebasePlaylist;
          }
          _currentState.loading = false;
          _firebaseController.add(_currentState);

        });

      }
    });
  }
}

class FirebaseBlocState {
  bool loading;
  FirebasePlaylist firebasePlaylist;

  FirebaseBlocState(this.loading, this.firebasePlaylist);

  FirebaseBlocState.empty() {
    loading = false;
    firebasePlaylist = null;
  }
}