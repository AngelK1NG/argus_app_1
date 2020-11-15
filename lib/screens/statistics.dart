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
import 'dart:async';

class StatisticsPage extends StatefulWidget {
  final Function goToPage;
  final Function shareStatistics;

  StatisticsPage(
      {@required this.goToPage, @required this.shareStatistics, Key key})
      : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  SharedPreferences _prefs;
  FirebaseUser _user;
  bool _loading = true;
  int _index = 0;
  Volts _initVolts;
  Volts _volts = Volts(dateTime: DateTime.now(), val: 0);
  String _date;
  List<Volts> _todayVolts = [];
  List<TaskItem> _tasks = [];
  num _voltsDelta = 0;
  Duration _timeFocused = Duration.zero;
  NumberFormat voltsFormat = NumberFormat('###,##0.00');
  int _completedTasks = 0;
  int _startedTasks = 0;
  int _totalTasks = 0;

  Future<void> getTasks() async {
    List<TaskItem> newTasks = [];
    int completedTasks = 0;
    int startedTasks = 0;
    int totalTasks = 0;
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
        newTasks.add(newTask);
        totalTasks++;
        if (task.data['completed']) {
          completedTasks++;
          startedTasks++;
        } else if (task.data['paused']) {
          startedTasks++;
        }
      });
      setState(() {
        _tasks = newTasks;
        _completedTasks = completedTasks;
        _startedTasks = startedTasks;
        _totalTasks = totalTasks;
      });
    }
  }

  Future<void> getVolts() async {
    DocumentSnapshot snapshot =
        await db.collection('users').document(_user.uid).get();
    if (mounted) {
      setState(() {
        _initVolts = Volts(
          dateTime: DateTime.parse(snapshot.data['volts']['dateTime']),
          val: snapshot.data['volts']['val'],
        );
        _volts = Volts(
          dateTime: DateTime.now(),
          val: snapshot.data['volts']['val'] -
              voltsDecay(
                seconds: (DateTime.now()
                    .difference(
                        DateTime.parse(snapshot.data['volts']['dateTime']))
                    .inSeconds),
                completedTasks: _completedTasks,
                startedTasks: _startedTasks,
                totalTasks: _totalTasks,
                volts: snapshot.data['volts']['val'],
              ),
        );
      });
    }
  }

  Future<void> getTodayVolts() async {
    List<Volts> newTodayVolts = [];
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
            'startedTasks': 0,
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
              newTodayVolts.add(Volts(
                  dateTime: DateTime.parse(volts['dateTime']),
                  val: volts['val']));
            });
          });
          newTodayVolts.add(_volts);
          setState(() {
            _timeFocused = Duration(seconds: snapshot.data['secondsFocused']);
            _voltsDelta = _volts.val - newTodayVolts.first.val;
            _todayVolts = newTodayVolts;
          });
        }
      }
    });
  }

  void getData() async {
    _prefs = await SharedPreferences.getInstance();
    _date = getDateString(DateTime.now().subtract(Duration(
        hours: _prefs.getInt('dayStartHour'),
        minutes: _prefs.getInt('dayStartMinute'))));
    await getTasks();
    await getVolts();
    switch (_index) {
      case 0:
        {
          await getTodayVolts();
        }
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void updateVolts() {
    if (mounted) {
      setState(() {
        _volts = Volts(
          dateTime: DateTime.now(),
          val: _initVolts.val -
              voltsDecay(
                seconds:
                    (DateTime.now().difference(_initVolts.dateTime).inSeconds),
                completedTasks: _completedTasks,
                startedTasks: _startedTasks,
                totalTasks: _totalTasks,
                volts: _initVolts.val,
              ),
        );
        _voltsDelta = _volts.val - _todayVolts.first.val;
        _todayVolts.last = _volts;
      });
    }
  }

  Widget taskColumn() {
    List<TaskStatTile> taskTiles = [];
    _tasks.forEach((task) {
      if (task.completed || task.paused) {
        taskTiles.add(TaskStatTile(task: task));
      }
    });
    if (taskTiles.isEmpty) {
      return Text(
        'Completed and paused tasks will show up here.',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    } else {
      return Column(children: taskTiles);
    }
  }

  Widget textButton(BuildContext context,
      {@required int index, @required String text}) {
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
    new Timer.periodic(
      const Duration(seconds: 2),
      (Timer timer) {
        updateVolts();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.goToPage(0),
      child: Stack(children: <Widget>[
        Positioned(
          left: 25,
          top: 25,
          child: Text(
            'Statistics',
            style: headerTextStyle,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 105,
          child: SizedBox(
            height: SizeConfig.safeBlockVertical * 100 - 185,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 25),
                                  child: Icon(
                                    FeatherIcons.zap,
                                    size: 24,
                                    color: jetBlack,
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
                            _todayVolts.length <= 1
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.only(left: 25, top: 15),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _volts.val >= _todayVolts.first.val
                                              ? FeatherIcons.chevronUp
                                              : FeatherIcons.chevronDown,
                                          size: 20,
                                          color: _volts.val >=
                                                  _todayVolts.first.val
                                              ? Theme.of(context).primaryColor
                                              : Colors.red,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 0),
                                          child: Icon(
                                            FeatherIcons.zap,
                                            size: 12,
                                            color: _volts.val >=
                                                    _todayVolts.first.val
                                                ? Theme.of(context).primaryColor
                                                : Colors.red,
                                          ),
                                        ),
                                        Text(
                                          '${voltsFormat.format(_voltsDelta.abs())} (${voltsFormat.format(_voltsDelta.abs() / _todayVolts.first.val * 100)}%)',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _volts.val >=
                                                    _todayVolts.first.val
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
                            _todayVolts.length <= 1
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.only(left: 25, top: 5),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${_timeFocused.inHours}h ${_timeFocused.inMinutes % 60}m',
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
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: GestureDetector(
                            onTap: () => widget.shareStatistics(
                              volts: _volts,
                              voltsList: _todayVolts,
                              voltsDelta: _voltsDelta,
                              timeFocused: _timeFocused,
                            ),
                            child: Container(
                              width: 110,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18)),
                                color: _todayVolts.length == 0
                                    ? Theme.of(context).primaryColor
                                    : _volts.val >= _todayVolts.first.val
                                        ? Theme.of(context).primaryColor
                                        : Colors.red,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    FeatherIcons.share,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Share Stats',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: SizedBox(
                        height: 150,
                        child: _todayVolts.length <= 1
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
                                        'Come back once you have completed at least one task.',
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
                              textButton(context, index: 0, text: 'Today'),
                              textButton(context, index: 1, text: 'Week'),
                              textButton(context, index: 2, text: 'Month'),
                              textButton(context, index: 3, text: 'All'),
                            ],
                          ),
                        ),
                        AnimatedPositioned(
                          child: Container(
                            width: 24,
                            height: 2,
                            decoration: BoxDecoration(
                              color: _todayVolts.length <= 1
                                  ? Theme.of(context).primaryColor
                                  : _volts.val >= _todayVolts.first.val
                                      ? Theme.of(context).primaryColor
                                      : Colors.red,
                              borderRadius: new BorderRadius.all(
                                Radius.circular(1),
                              ),
                            ),
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
                        'Today\'s Tasks',
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
