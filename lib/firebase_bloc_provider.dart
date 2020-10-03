import 'package:flutter/material.dart';

import 'firebase_bloc.dart';

class FirebaseBlocProvider extends InheritedWidget {
  final FirebaseBloc bloc;
  final Widget child;

  FirebaseBlocProvider({this.bloc, this.child}) : super(child: child);
  static FirebaseBlocProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FirebaseBlocProvider>();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}