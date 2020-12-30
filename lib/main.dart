import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'screens/login.dart';
import 'constants.dart';

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
  final facebookAppEvents = FacebookAppEvents();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<User>(
      create: (_) => User(),
      child: KeyboardVisibilityProvider(
        child: KeyboardDismissOnTap(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overscroll) {
              overscroll.disallowGlow();
              return null;
            },
            child: MaterialApp(
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
                      animationDuration: cardDuration,
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
                onGenerateRoute: (routeSettings) {
                  switch (routeSettings.name) {
                    default:
                      {
                        return PageRouteBuilder(
                          settings: RouteSettings(name: routeSettings.name),
                          pageBuilder: (_, a1, a2) => LoginPage(),
                        );
                      }
                  }
                }),
          ),
        ),
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
