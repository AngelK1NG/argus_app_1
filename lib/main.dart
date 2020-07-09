import 'package:flutter/material.dart';
import 'Screens/HomePage.dart';
import 'Screens/TasksPage.dart';
import 'Screens/StatisticsPage.dart';
import 'Screens/SettingsPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          height: 60,
          minWidth: 60,
        ),
        accentColor: const Color(0xff3c25d7),
      ),
      home: Scaffold(
        body: SizedBox.expand(
          child: HomePage(),
        ),
      ),
      routes: {
        '/tasks': (context) {
          return(
            Scaffold(
              body: SizedBox.expand(
                child: TasksPage(),
              ),
            )
          );
        },
        '/statistics': (context) {
          return(
            Scaffold(
              body: SizedBox.expand(
                child: StatisticsPage(),
              ),
            )
          );
        },
        '/settings': (context) {
          return(
            Scaffold(
              body: SizedBox.expand(
                child: SettingsPage(),
              ),
            )
          );
        },
      }
    );
  }
}