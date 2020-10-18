import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/utils/date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/components/volts.dart';
import 'package:Focal/components/volts_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:Focal/components/task_item.dart';
import 'package:Focal/components/task_stat_tile.dart';

class StatisticsPage extends StatefulWidget {
  final Function goToPage;

  StatisticsPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  SharedPreferences _prefs;
  FirebaseUser _user;
  bool _loading = true;
  int _index = 0;
  Volts _volts = Volts(dateTime: DateTime.now(), val: 0);
  String _date;
  List<Volts> _todayVolts = [];
  List<TaskItem> _tasks = [];
  Duration _timeFocused = Duration.zero;
  NumberFormat voltsFormat = NumberFormat('###,###.00');

  Future<void> getVolts() async {
    DocumentSnapshot snapshot =
        await db.collection('users').document(_user.uid).get();
    if (mounted) {
      setState(() {
        _volts = Volts(
            dateTime: DateTime.now(),
            val: snapshot.data['volts']['val'] -
                0.02 *
                    (DateTime.now()
                        .difference(
                            DateTime.parse(snapshot.data['volts']['dateTime']))
                        .inSeconds));
      });
    }
  }

  Future<void> getTodayVolts() async {
    DocumentReference dateDoc = db
        .collection('users')
        .document(_user.uid)
        .collection('dates')
        .document(_date);
    dateDoc.get().then((snapshot) {
      if (mounted) {
        if (snapshot.data == null) {
          dateDoc.setData({
            'completedTasks': 0,
            'totalTasks': 0,
            'secondsFocused': 0,
            'secondsDistracted': 0,
            'numDistracted': 0,
            'numPaused': 0,
            'volts': [],
          });
        } else {
          snapshot.data['volts'].forEach((volts) {
            setState(() {
              _todayVolts.add(Volts(
                  dateTime: DateTime.parse(volts['dateTime']),
                  val: volts['val']));
            });
          });
          _todayVolts.add(_volts);
          setState(() {
            _timeFocused = Duration(seconds: snapshot.data['secondsFocused']);
          });
        }
      }
    });
  }

  Future<void> getTasks() async {
    QuerySnapshot snapshot = await db
        .collection('users')
        .document(_user.uid)
        .collection('dates')
        .document(_date)
        .collection('tasks')
        .orderBy('order')
        .getDocuments();
    if (mounted) {
      snapshot.documents.forEach((task) {
        String name = task.data['name'];
        TaskItem newTask = TaskItem(
          name: name,
          id: task.documentID,
          completed: task.data['completed'],
          paused: task.data['paused'],
          order: task.data['order'],
          secondsFocused: task.data['secondsFocused'],
          secondsDistracted: task.data['secondsDistracted'],
          key: UniqueKey(),
          date: _date,
        );
        setState(() {
          _tasks.add(newTask);
        });
      });
    }
  }

  void getData() async {
    _prefs = await SharedPreferences.getInstance();
    _date = getDateString(DateTime.now().subtract(Duration(
        hours: _prefs.getInt('dayStartHour'),
        minutes: _prefs.getInt('dayStartMinute'))));
    await getVolts();
    await getTodayVolts();
    await getTasks();
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget taskColumn() {
    List<TaskStatTile> taskTiles = [];
    _tasks.forEach((task) {
      if (task.completed) {
        taskTiles.add(TaskStatTile(task: task));
      }
    });
    _tasks.forEach((task) {
      if (task.paused && !task.completed) {
        taskTiles.add(TaskStatTile(task: task));
      }
    });
    return Column(children: taskTiles);
  }

  Widget textButton(BuildContext context, int index, String text) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          _index = index;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _todayVolts.length == 0
                ? Theme.of(context).primaryColor
                : _volts.val >= _todayVolts.first.val
                    ? Theme.of(context).primaryColor
                    : Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false).user;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.goToPage(0),
      child: Stack(children: <Widget>[
        Positioned(
          left: 25,
          top: SizeConfig.safeBlockVertical * 5,
          child: Text(
            'Statistics',
            style: headerTextStyle,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: SizeConfig.safeBlockVertical * 15 + 25,
          child: SizedBox(
            height: SizeConfig.safeBlockVertical * 85 - 105,
            child: AnimatedOpacity(
              opacity: _loading ? 0 : 1,
              duration: loadingDuration,
              curve: loadingCurve,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 25, right: 5),
                          child: Icon(
                            FeatherIcons.zap,
                            size: 24,
                          ),
                        ),
                        Text(
                          voltsFormat.format(_volts.val),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    _todayVolts.length == 0
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(left: 25, top: 15),
                            child: Row(
                              children: [
                                Icon(
                                  _volts.val >= _todayVolts.first.val
                                      ? FeatherIcons.arrowUpRight
                                      : FeatherIcons.arrowDownRight,
                                  size: 20,
                                  color: _volts.val >= _todayVolts.first.val
                                      ? Theme.of(context).primaryColor
                                      : Colors.red,
                                ),
                                Text(
                                  '${voltsFormat.format(_volts.val - _todayVolts.first.val)} (${voltsFormat.format((_volts.val - _todayVolts.first.val) / _todayVolts.first.val * 100)}%)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _volts.val >= _todayVolts.first.val
                                        ? Theme.of(context).primaryColor
                                        : Colors.red,
                                  ),
                                ),
                                Text(
                                  ' Today',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                    _todayVolts.length == 0
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(left: 25, top: 5),
                            child: Row(
                              children: [
                                Text(
                                  '${_timeFocused.inHours}h ${_timeFocused.inMinutes}m',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  ' Focused',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                    Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: SizedBox(
                        height: 150,
                        child: _todayVolts.length == 0
                            ? Container(
                                padding: EdgeInsets.only(left: 80, right: 80),
                                child: Column(
                                  children: [
                                    Text(
                                      'You haven\'t done any tasks yet.',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text(
                                        'Come back once you have completed some tasks.',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : VoltsChart(data: _todayVolts, id: 'todayVolts'),
                      ),
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              textButton(context, 0, 'Today'),
                              textButton(context, 1, 'Week'),
                              textButton(context, 2, 'Month'),
                              textButton(context, 3, 'All'),
                            ],
                          ),
                        ),
                        AnimatedPositioned(
                          child: Container(
                            width: 24,
                            height: 2,
                            color: _todayVolts.length == 0
                                ? Theme.of(context).primaryColor
                                : _volts.val >= _todayVolts.first.val
                                    ? Theme.of(context).primaryColor
                                    : Colors.red,
                          ),
                          duration: loadingDuration,
                          curve: loadingCurve,
                          left: _index == 0
                              ? (SizeConfig.safeBlockHorizontal * 100 -
                                          4 * 48) /
                                      5 +
                                  12
                              : _index == 1
                                  ? (SizeConfig.safeBlockHorizontal * 100 -
                                              4 * 48) /
                                          5 *
                                          2 +
                                      60
                                  : _index == 2
                                      ? (SizeConfig.safeBlockHorizontal * 100 -
                                                  4 * 48) /
                                              5 *
                                              3 +
                                          108
                                      : (SizeConfig.safeBlockHorizontal * 100 -
                                                  4 * 48) /
                                              5 *
                                              4 +
                                          156,
                          bottom: 20,
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 25, left: 25, right: 25),
                      child: Text(
                        'You completed 8 tasks today! That’s 3 more than yesterday and 2 more than your daily average!',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25, top: 50, bottom: 10),
                      child: Text(
                        'Tasks',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25, right: 25),
                      child: taskColumn(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
