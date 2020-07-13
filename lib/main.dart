import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Screens/HomePage.dart';
import 'Screens/TasksPage.dart';
import 'Screens/StatisticsPage.dart';
import 'Screens/SettingsPage.dart';
import 'Screens/LoginPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          height: 60,
          minWidth: 60,
        ),
        accentColor: const Color(0xff3c25d7),
        splashColor: Colors.transparent,
      ),
      initialRoute: '/login',
      routes: {
        '/home': (context) {
          return HomePage();
        },
        '/tasks': (context) {
          return TasksPage();
        },
        '/statistics': (context) {
          return StatisticsPage();
        },
        '/settings': (context) {
          return SettingsPage();
        },
        '/login': (context) {
          return LoginPage();
        }
      },
    );
  }
}
