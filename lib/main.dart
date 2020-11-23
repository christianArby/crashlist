import 'package:crashlist/crashlist/crashlist_cubit.dart';
import 'package:crashlist/list/list_cubit.dart';
import 'package:crashlist/firebase_repository.dart';
import 'package:crashlist/player_repository.dart';
import 'package:crashlist/player_view/player_view_cubit.dart';
import 'package:crashlist/player_view/player_view_screen.dart';
import 'package:crashlist/playlist/playlist_cubit.dart';
import 'package:crashlist/spotify_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'crashlist/crashlist_screen.dart';
import 'list/list_screen.dart';

Future<void> main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseRepository = FirebaseRepository();
    firebaseRepository.init();
    final spotifyRepository = SpotifyRepository();
    final playerRepository = PlayerRepository(firebaseRepository, spotifyRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CrashlistCubit(firebaseRepository, playerRepository)),
        BlocProvider(create: (context) => ListCubit(spotifyRepository)),
        BlocProvider(create: (context) => PlaylistCubit(spotifyRepository, firebaseRepository)),
        BlocProvider(create: (context) => PlayerViewCubit()),
      ],
      child: MaterialApp(

        title: 'Crashlist',

        home: BottomBar(),
        theme: ThemeData.dark(),
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class BottomBar extends StatefulWidget {
  BottomBar({Key key}) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

/// This is the private State class that goes with MyStatefulWidget._widgetOptions.elementAt(_selectedIndex)
class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    CrashlistScreen(),
    ListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PlayerViewScreen()
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Business'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
