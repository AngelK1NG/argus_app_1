import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/onboarding.dart';
import 'components/wrapper.dart';
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return ChangeNotifierProvider<User>(
      create: (_) => User(),
      child: KeyboardVisibilityProvider(
        child: KeyboardDismissOnTap(
          child: MaterialApp(
              navigatorKey: navigatorKey,
              theme: ThemeData(
                buttonTheme: ButtonThemeData(
                  height: 60,
                  minWidth: 60,
                ),
                primarySwatch: focalPurple,
                primaryColor: const Color(0xff3c25d7),
                accentColor: const Color(0xff7c4efd),
                hintColor: const Color(0xffb0b0b0),
                dividerColor: const Color(0xffe5e5e5),
                splashColor: Colors.transparent,
                textSelectionColor: const Color(0xffddddff),
                textTheme: Theme.of(context)
                    .textTheme
                    .apply(bodyColor: jetBlack, displayColor: jetBlack),
              ),
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
              ],
              onGenerateRoute: (routeSettings) {
                switch (routeSettings.name) {
                  case '/home':
                    return PageRouteBuilder(
                        settings: RouteSettings(name: routeSettings.name),
                        pageBuilder: (_, a1, a2) =>
                            WrapperWidget(child: Home()));
                    break;
                  case '/onboarding':
                    return PageRouteBuilder(
                        settings: RouteSettings(name: routeSettings.name),
                        pageBuilder: (_, a1, a2) =>
                            WrapperWidget(child: Onboarding()));
                    break;
                  default:
                    return PageRouteBuilder(
                        settings: RouteSettings(name: routeSettings.name),
                        pageBuilder: (_, a1, a2) =>
                            WrapperWidget(child: LoginPage()));
                    break;
                }
              }),
        ),
      ),
    );
  }
}

const MaterialColor focalPurple =
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
