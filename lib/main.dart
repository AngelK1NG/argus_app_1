import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'screens/tasks.dart';
import 'screens/statistics.dart';
import 'screens/settings.dart';
import 'screens/login.dart';

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
    return ChangeNotifierProvider<User>(
      create: (_) => User(),
      child: MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData(
            buttonTheme: ButtonThemeData(
              height: 60,
              minWidth: 60,
            ),
            primarySwatch: focalPurple,
            primaryColor: const Color(0xff3c25d7),
            accentColor: const Color(0xff3c25d7),
            hintColor: const Color(0xffb0b0b0),
            dividerColor: const Color(0xffe2e2e2),
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
          }),
    );
  }
}

const MaterialColor focalPurple = const MaterialColor(
  0xff3c25d7,
  const <int, Color> {
    50: const Color(0xff3c25d7),
    100: const Color(0xff3c25d7),
    200: const Color(0xff3c25d7),
    300: const Color(0xff3c25d7),
    400: const Color(0xff3c25d7),
    500: const Color(0xff3c25d7),
    600: const Color(0xff3c25d7),
    700: const Color(0xff3c25d7),
    800: const Color(0xff3c25d7),
    900: const Color(0xff3c25d7),
  }
);
