import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:provider/provider.dart';
import 'package:Focal/screens/home.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      StreamProvider<User>.value(
        value: AuthProvider().onAuthStateChanged(),
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();
  final facebookAppEvents = FacebookAppEvents();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            minimumSize: MaterialStateProperty.all(
              Size(50, 50),
            ),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            animationDuration: buttonDuration,
          ),
        ),
        primarySwatch: materialBlue,
        primaryColor: blue,
        primaryColorLight: purple,
        accentColor: blue,
        dividerColor: dividerColor,
        hintColor: hintColor,
        splashColor: Colors.transparent,
        shadowColor: shadowColor,
        textSelectionColor: textSelectionColor,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: black,
              displayColor: black,
              fontFamily: 'Cabin',
            ),
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
      ],
      home: MultiProvider(
        providers: [
          StreamProvider<UncompletedTasks>.value(
            value: DatabaseProvider()
                .streamUncompleted(Provider.of<User>(context)),
            initialData: UncompletedTasks(null),
          ),
          StreamProvider<CompletedTasks>.value(
            value:
                DatabaseProvider().streamCompleted(Provider.of<User>(context)),
            initialData: CompletedTasks(null),
          ),
        ],
        child: Home(),
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
