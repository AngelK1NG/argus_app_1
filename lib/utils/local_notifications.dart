import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Focal/constants.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotifications {
  SharedPreferences _prefs;

  void initialize() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectionNotification);
    _prefs = await SharedPreferences.getInstance();
  }

  void showDistractedNotification() async {
    if (_prefs.getBool('distractedNotification')) {
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'Distracted Notification',
        'Distracted Notification',
        'Notify when Distracted',
        priority: Priority.High,
        importance: Importance.Max,
      );
      IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
      NotificationDetails notificationDetails =
          NotificationDetails(androidNotificationDetails, iosNotificationDetails);
      await notificationsPlugin.show(0, 'You\'re getting Distracted!',
          'You\'re losing Volts, come back before it\'s too late!', notificationDetails);
      print('Distracted, notification sent');
    }
  }

  // ignore: missing_return
  Future onSelectionNotification(String payLoad) {}

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
