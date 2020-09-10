import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/today_stats.dart';
import 'package:Focal/components/week_stats.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/utils/date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:Focal/utils/user.dart';

class StatisticsPage extends StatefulWidget {
  final Function goToPage;
  
  StatisticsPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _loading = true;
  String _timeFrame = 'today';
  QuerySnapshot _todayTasksSnapshot;
  DocumentSnapshot _todayDateSnapshot;
  List<Map> _weekSnapshots = [];

  Future<void> getThisWeeksDays() async {}

  Future<void> getTodaySnapshots() async {
    FirebaseUser user = context.read<User>().user;
    await db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(getDateString(DateTime.now()))
        .collection('tasks')
        .orderBy('order')
        .getDocuments()
        .then((snapshot) {
      _todayTasksSnapshot = snapshot;
    });
    await db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(getDateString(DateTime.now()))
        .get()
        .then((snapshot) {
      _todayDateSnapshot = snapshot;
    });
  }

  Future<void> getWeekSnapshots() async {
    List<String> days = [];
    var now = DateTime.now();
    if (now.weekday != 7) {
      now = now.subtract(new Duration(days: now.weekday));
    }
    days.add(getDateString(now));
    now = now.add(new Duration(days: 1));
    while (now.weekday != 7) {
      days.add(getDateString(now));
      now = now.add(new Duration(days: 1));
    }
    FirebaseUser _user = Provider.of<User>(context, listen: false).user;
    days.forEach((day) async {
      await db
          .collection('users')
          .document(_user.uid)
          .collection('tasks')
          .document(day)
          .get()
          .then((snapshot) {
        if (snapshot == null) {
          _weekSnapshots.add({'data': null});
        } else {
          _weekSnapshots
              .add({'documentID': snapshot.documentID, 'data': snapshot.data});
        }
      });
    });
  }

  Future<void> getSnapshots() async {
    await getThisWeeksDays();
    await getTodaySnapshots();
    await getWeekSnapshots();
    Future.delayed(cardSlideDuration, () {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getSnapshots();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.goToPage(0),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 30,
            top: SizeConfig.safeBlockVertical * 5,
            child: Text(
              'Statistics',
              style: headerTextStyle,
            ),
          ),
          AnimatedOpacity(
            opacity: _loading ? 0 : 1,
            duration: loadingDuration,
            curve: loadingCurve,
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: 0,
                  left: 0,
                  top: SizeConfig.safeBlockVertical * 15 + 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          if (_timeFrame != 'today') {
                            setState(() {
                              _timeFrame = 'today';
                            });
                          }
                        },
                        child: Container(
                          height: 30,
                          width: SizeConfig.safeBlockHorizontal * 50 - 30,
                          decoration: BoxDecoration(
                              color: _timeFrame == 'today'
                                  ? Theme.of(context).accentColor
                                  : Theme.of(context).dividerColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15))),
                          child: Center(
                            child: Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 12,
                                color: _timeFrame == 'today'
                                    ? Colors.white
                                    : Theme.of(context).accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_timeFrame != 'week') {
                            setState(() {
                              _timeFrame = 'week';
                            });
                          }
                        },
                        child: Container(
                          height: 30,
                          width: SizeConfig.safeBlockHorizontal * 50 - 30,
                          decoration: BoxDecoration(
                              color: _timeFrame == 'week'
                                  ? Theme.of(context).accentColor
                                  : Theme.of(context).dividerColor,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15))),
                          child: Center(
                            child: Text(
                              'Week',
                              style: TextStyle(
                                fontSize: 12,
                                color: _timeFrame == 'week'
                                    ? Colors.white
                                    : Theme.of(context).accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    right: 30,
                    left: 30,
                    top: SizeConfig.safeBlockVertical * 15 + 80,
                    child: SizedBox(
                      height: SizeConfig.safeBlockVertical * 85 - 80,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: _loading
                            ? Container()
                            : _timeFrame == 'today'
                                ? TodayStats(
                                    tasksSnapshot: _todayTasksSnapshot,
                                    dateSnapshot: _todayDateSnapshot)
                                : WeekStats(snapshots: _weekSnapshots),
                      ),
                    )),
              ],
            ),
          ),
        ]
      ),
    );
  }
}
