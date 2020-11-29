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
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

//loading delay
final Duration loadingDelay = Duration(milliseconds: 2000);

//animation transitions
final Duration cardDuration = Duration(milliseconds: 200);
final Curve cardCurve = Curves.ease;

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
  increment = 0.01 *
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
