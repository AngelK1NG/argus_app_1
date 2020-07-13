import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Screens/HomePage.dart';
import 'Screens/TasksPage.dart';
import 'Screens/StatisticsPage.dart';
import 'Screens/SettingsPage.dart';
import 'Screens/LoginPage.dart';
import 'package:Focal/utils/firebase_auth.dart';
import 'package:provider/provider.dart';

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
  Widget checkCurrentUser(Widget screen) {
    print(AuthProvider().user);
    if (AuthProvider().user != null) {
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
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(value: AuthProvider().user),
      ],
      child: MaterialApp(
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
          '/login': (context) {
            return checkCurrentUser(LoginPage());
          }
        },
      ),
    );
  }
}
