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
      elevation: MaterialStateProperty.all(5),
      animationDuration: buttonDuration,
    ),
  ),
  primaryColor: Color(0xff3c25d7),
  accentColor: Color(0xff3c25d7),
  hintColor: Color(0xffbbbbbb),
  dividerColor: Color(0xffdddddd),
  shadowColor: Color(0xff111111).withOpacity(0.2),
  textSelectionColor: Color(0xffddddff),
  backgroundColor: Color(0xffffffff),
  cursorColor: Color(0xff3c25d7),
  splashColor: Colors.transparent,
);

//dark theme
final ThemeData darkTheme = ThemeData(
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
      elevation: MaterialStateProperty.all(5),
      animationDuration: buttonDuration,
    ),
  ),
  primaryColor: Color(0xff7c4efd),
  accentColor: Color(0xff7c4efd),
  hintColor: Color(0xff888888),
  dividerColor: Color(0xff333333),
  shadowColor: black.withOpacity(0.2),
  textSelectionColor: Color(0xffddddff),
  backgroundColor: Color(0xff111111),
  cursorColor: Color(0xff7c4efd),
  splashColor: Colors.transparent,
);

//colors
final Color black = Color(0xff111111);
final Color white = Color(0xffffffff);
final Color blue = Color(0xff3c25d7);
final Color purple = Color(0xff7c4efd);
final Color red = Color(0xfff44236);

//text styles
final TextStyle buttonTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Colors.white,
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
