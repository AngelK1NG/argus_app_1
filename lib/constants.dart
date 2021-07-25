import 'package:flutter/material.dart';

//light theme
final ThemeData lightTheme = ThemeData(
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
      elevation: MaterialStateProperty.resolveWith(getElevation),
      animationDuration: buttonDuration,
    ),
  ),
  primaryColor: Color(0xff111133),
  backgroundColor: Color(0xffdce5e8),
  accentColor: Color(0xff1aafd8),
  hintColor: Color(0xff888888),
  splashColor: Colors.transparent,
);

double getElevation(Set<MaterialState> states) {
  if (states.any([MaterialState.pressed].contains)) {
    return 0;
  }
  return 5;
}

//colors
final Color black = Color(0xff111133);
final Color white = Color(0xffffffff);
final Color blue = Color(0xff3c25d7);
final Color purple = Color(0xff7c4efd);
final Color red = Color(0xfff44236);

//text styles
final TextStyle buttonTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: white,
);

//animation transitions
final Duration fadeDuration = Duration(milliseconds: 200);
final Curve fadeCurve = Curves.ease;

final Duration overlayDuration = Duration(milliseconds: 500);
final Curve overlayCurve = Curves.easeOutQuint;

final Duration buttonDuration = Duration(milliseconds: 200);
final Curve buttonCurve = Curves.ease;

final Duration loginDuration = Duration(milliseconds: 800);
final Curve loginCurve = Curves.ease;
