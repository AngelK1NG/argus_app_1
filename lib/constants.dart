import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

//firebase
final FirebaseAuth auth = FirebaseAuth.instance;
final Firestore db = Firestore.instance;
final FirebaseAnalytics analytics = FirebaseAnalytics();

// local notifications
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

//colors
final Color jetBlack = Color(0xff2b2b2b);

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
