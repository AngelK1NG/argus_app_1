import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Focal/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotifications {
  SharedPreferences _prefs;

  void initialize() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    _prefs = await SharedPreferences.getInstance();
  }

  void distractedNotification() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'Distracted Notification',
      'Distracted Notification',
      'Notify when Distracted',
      priority: Priority.high,
      importance: Importance.max,
    );
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);
    await notificationsPlugin.show(
      0,
      'You\'re getting Distracted!',
      'You\'re losing Volts, come back before it\'s too late!',
      notificationDetails,
    );
    if (_prefs.getBool('repeatDistractedNotification')) {
      await notificationsPlugin.periodicallyShow(
        0,
        'You\'re still Distracted!',
        'Are you still doing your task? You\'re losing Volts!',
        RepeatInterval.everyMinute,
        notificationDetails,
        androidAllowWhileIdle: true,
      );
    }
  }

  void cancelDistractedNotification() async {
    await notificationsPlugin.cancel(0);
  }

  Future selectNotification(String payLoad) {
    return null;
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payLoad) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {},
          child: Text('OK'),
        ),
      ],
    );
  }
}
