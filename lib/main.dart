import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:vivi/screens/home.dart';
import 'package:vivi/constants.dart';
import 'package:vivi/utils/auth.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  runApp(
    StreamProvider<UserStatus>.value(
      value: AuthProvider().onAuthStateChanged(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overscroll) {
        overscroll.disallowGlow();
        return null;
      },
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: lightTheme.copyWith(
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: black,
                displayColor: black,
                fontFamily: 'Cabin',
              ),
        ),
        home: Home(),
      ),
    );
  }
}

const MaterialColor materialBlue =
    const MaterialColor(0xff3c25d7, const <int, Color>{
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
});
