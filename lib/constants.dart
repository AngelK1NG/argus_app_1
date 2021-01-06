import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:math';

//firebase
final FirebaseAuth auth = FirebaseAuth.instance;
final Firestore db = Firestore.instance;
final FirebaseAnalytics analytics = FirebaseAnalytics();

//local notifications
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

//main colors
final Color black = Color(0xff111111);
final Color white = Color(0xffffffff);
final Color blue = Color(0xff3c25d7);
final Color purple = Color(0xff7c4efd);
final Color red = Color(0xfff44236);

//utility colors
final Color hintColor = Color(0xffb0b0b0);
final Color shadowColor = black.withOpacity(0.2);
final Color dividerColor = Color(0xffe5e5e5);
final Color textSelectionColor = Color(0xffddddff);

//text styles
final TextStyle whiteHeaderTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);
final TextStyle blackHeaderTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);
final TextStyle buttonTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

//animation transitions
final Duration generalDuration = Duration(milliseconds: 200);
final Curve generalCurve = Curves.ease;

final Duration loginDuration = Duration(milliseconds: 800);
final Curve loginCurve = Curves.ease;

final Duration keyboardDuration = Duration(milliseconds: 500);
final Curve keyboardCurve = Cubic(0.380, 0.700, 0.125, 1.000);

final Duration buttonDuration = Duration(milliseconds: 200);
final Curve buttonCurve = Curves.ease;

final Duration snackbarDuration = Duration(milliseconds: 2000);
final Duration focusNoticeDuration = Duration(milliseconds: 4000);

//algorithms
num voltsIncrement({
  @required int secondsFocused,
  @required int secondsDistracted,
  @required int numPaused,
  @required int completedTasks,
  @required int totalTasks,
  @required num volts,
}) {
  num increment = 0;
  increment = 0.005 *
      (secondsFocused - secondsDistracted) *
      pow(100 * (completedTasks + 1) / totalTasks, 0.1) *
      pow(totalTasks, 0.1) /
      pow(numPaused + 1, 0.2);
  if (-increment < volts) {
    return increment;
  } else {
    return -volts;
  }
}

num voltsDecay({
  @required int seconds,
  @required int completedTasks,
  @required int startedTasks,
  @required int totalTasks,
  @required num volts,
}) {
  num decay = 0;
  if (startedTasks != 0 && completedTasks != totalTasks) {
    decay = 0.1 *
            pow(seconds, 0.5) *
            pow(100 * startedTasks / totalTasks, 0.1) *
            pow(totalTasks, 0.1) +
        pow((seconds % 4) + 1, 0.03) * pow((seconds % 5) + 1, 0.03) -
        1;
  }
  if (decay < volts) {
    return decay;
  } else {
    return volts;
  }
}
