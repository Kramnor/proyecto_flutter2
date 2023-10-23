import 'package:crud_firebase/screens.dart';
import 'package:flutter/material.dart';

class Approutes {
  static const initialRoute = 'login';

  static Map<String, Widget Function(BuildContext)> routes = {
    'home': (BuildContext context) => const Home(),
    'login': (BuildContext context) => const AuthScreen(),
    'crud': (BuildContext context) => const Crud()
  };
}
