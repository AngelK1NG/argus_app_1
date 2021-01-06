import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Focal/utils/local_notifications.dart';

class FocusPage extends StatefulWidget {
  final Function goToPage;

  FocusPage({
    @required this.goToPage,
    Key key,
  }) : super(key: key);

  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> with WidgetsBindingObserver {
  LocalNotifications localNotifications;

  void startTask() async {}

  void stopTask() {}

  void pauseTask() {}

  void completeTask() {}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      child: Stack(
        children: <Widget>[
          Container(),
        ],
      ),
    );
  }
}
