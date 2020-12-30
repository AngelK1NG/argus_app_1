import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/utils/local_notifications.dart';
import 'package:Focal/constants.dart';

class FocusPage extends StatefulWidget {
  final Function goToPage;
  final Function setLoading;
  final Function setNav;
  final Function setDoingTask;

  FocusPage({
    @required this.goToPage,
    @required this.setLoading,
    @required this.setNav,
    @required this.setDoingTask,
    Key key,
  }) : super(key: key);

  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> with WidgetsBindingObserver {
  LocalNotifications localNotifications;
  bool _loading = true;

  void startTask() async {}

  void stopTask() {}

  void pauseTask() {}

  void completeTask() {}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(loadingDelay, () {
      if (_loading && mounted) {
        widget.setLoading(true);
      }
    });
    localNotifications = LocalNotifications();
    localNotifications.initialize();
    localNotifications.cancelDistractedNotification();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AnimatedOpacity(
        opacity: _loading ? 0 : 1,
        duration: cardDuration,
        curve: cardCurve,
        child: Stack(
          children: <Widget>[
            Container(),
          ],
        ),
      ),
    );
  }
}
