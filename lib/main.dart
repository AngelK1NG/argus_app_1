import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Screens/HomePage.dart';
import 'Screens/TasksPage.dart';
import 'Screens/StatisticsPage.dart';
import 'Screens/SettingsPage.dart';
import 'Screens/LoginPage.dart';
import 'package:Focal/utils/firebase_auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loggedIn = false;

  Widget checkCurrentUser(Widget screen) {
    if (_loggedIn) {
      return Scaffold(
        body: SizedBox.expand(
          child: screen,
        ),
      );
    } else {
      return Scaffold(
        body: SizedBox.expand(
          child: LoginPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _auth.onAuthStateChanged.listen((firebaseUser) {
      if (firebaseUser != null) {
        _loggedIn = false;
      } else {
        _loggedIn = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          height: 60,
          minWidth: 60,
        ),
        accentColor: const Color(0xff3c25d7),
        splashColor: Colors.transparent,
      ),
      home: checkCurrentUser(HomePage()),
      routes: {
        '/tasks': (context) {
          return checkCurrentUser(TasksPage());
        },
        '/statistics': (context) {
          return checkCurrentUser(StatisticsPage());
        },
        '/settings': (context) {
          return checkCurrentUser(SettingsPage());
        },
      },
    );
  }
}
