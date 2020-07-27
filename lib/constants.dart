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
final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

//styles
final Color primaryTextColor = Color(0xff2b2b2b);
final Color indicatorBackgroundColor = Color(0xffe5e5e5);

//animation transitions
final Duration navDuration = Duration(milliseconds: 200);
final Duration cardSlideDuration = Duration(milliseconds: 200);
final Curve cardSlideCurve = Curves.ease;
