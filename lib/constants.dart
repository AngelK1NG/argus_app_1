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

// local notifications
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

//colors
final Color jetBlack = Color(0xff2b2b2b);
final Color darkRed = Color(0xffd54321);

//styles
final TextStyle headerTextStyle = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

//animation transitions
final Duration loadingDuration = Duration(milliseconds: 200);
final Curve loadingCurve = Curves.ease;

final Duration cardSlideDuration = Duration(milliseconds: 200);
final Curve cardSlideCurve = Curves.ease;

final Duration keyboardDuration = Duration(milliseconds: 600);
final Curve keyboardCurve = Cubic(0.380, 0.700, 0.125, 1.000);

final Duration buttonDuration = Duration(milliseconds: 200);
final Curve buttonCurve = Curves.ease;

final Duration snackbarDuration = Duration(milliseconds: 2000);

//algorithms
num voltsIncrement({
  @required int secondsFocused,
  @required int secondsDistracted,
  @required int numPaused,
  @required int completedTasks,
  @required int totalTasks,
}) {
  return 0.05 *
      (secondsFocused - pow(secondsDistracted, 1.2) - numPaused) *
      pow(100 * ((completedTasks + 1) / totalTasks), 0.1) *
      pow(totalTasks, 0.1);
}

num voltsDecay({
  @required int seconds,
  @required num voltsDelta,
  @required int completedTasks,
  @required int totalTasks,
}) {
  return 0.005 *
      (seconds + voltsDelta + 100 * (totalTasks - completedTasks) / totalTasks);
}
