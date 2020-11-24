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
import 'package:Focal/components/stats_task_item.dart';
import 'dart:async';
import 'dart:math';

class StatisticsPage extends StatefulWidget {
  final Function goToPage;
  final Function setLoading;
  final Function shareStatistics;

  StatisticsPage({
    @required this.goToPage,
    @required this.setLoading,
    @required this.shareStatistics,
    Key key,
  }) : super(key: key);

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
  String _text = '';
  List<Volts> _todayVolts = [];
  List<Volts> _weekVolts = [];
  List<Volts> _monthVolts = [];
  List<Volts> _allVolts = [];
  List<TaskItem> _tasks = [];
  num _voltsDelta = 0;
  Duration _timeFocused = Duration.zero;
  Duration _avgFocused;
  NumberFormat voltsFormat = NumberFormat('###,##0.00');
  int _completedTasks = 0;
  int _startedTasks = 0;
  int _totalTasks = 0;
  int _avgTasks;
  Random _random = Random();

  final quotes = [
    '''“You can waste your lives drawing lines. Or you can live your life crossing them.”''',
    '''“Everything comes to him who hustles while he waits.”''',
    '''"The only difference between ordinary and extraordinary is that little extra."''',
    '''"The secret of getting ahead is getting started."''',
    '''"The way to get started is to quit talking and begin doing."''',
    '''"Don't ask. Act! Action will delineate and define you."''',
    '''“It’s not knowing what to do; it’s doing what you know.”''',
    '''“The big secret in life is that there is no big secret. Whatever your goal, you can get there if you’re willing to work.”''',
    '''“Action is the foundational key to all success.”''',
    '''“Amateurs sit and wait for inspiration, the rest of us just get up and go to work.”''',
  ];

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
          numPaused: task.data['numPaused'],
          numDistracted: task.data['numDistracted'],
          voltsIncrement: task.data['voltsIncrement'],
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

  Future<void> getVoltsList() async {
    List<Volts> tempVolts = [];
    int decrement;
    QuerySnapshot snapshot;
    DocumentSnapshot userSnapshot;
    final index = _index;
    switch (index) {
      case 0:
        {
          if (_todayVolts.isNotEmpty) {
            return;
          } else {
            decrement = 0;
          }
          break;
        }
      case 1:
        {
          if (_weekVolts.isNotEmpty) {
            return;
          } else {
            decrement = 6;
          }
          break;
        }
      case 2:
        {
          if (_monthVolts.isNotEmpty) {
            return;
          } else {
            decrement = 29;
          }
          break;
        }
      case 3:
        {
          if (_allVolts.isNotEmpty) {
            return;
          } else {
            snapshot = await db
                .collection('users')
                .document(_user.uid)
                .collection('dates')
                .where(FieldPath.documentId, isLessThanOrEqualTo: _date)
                .getDocuments();
            snapshot.documents.forEach((DocumentSnapshot document) {
              if (mounted) {
                if (document.data != null) {
                  document.data['volts'].forEach((volts) {
                    setState(() {
                      tempVolts.add(Volts(
                          dateTime: DateTime.parse(volts['dateTime']),
                          val: volts['val']));
                    });
                  });
                }
              }
            });
            userSnapshot =
                await db.collection('users').document(_user.uid).get();
            if (mounted) {
              setState(() {
                _initVolts = Volts(
                  dateTime:
                      DateTime.parse(userSnapshot.data['volts']['dateTime']),
                  val: userSnapshot.data['volts']['val'],
                );
                _volts = Volts(
                  dateTime: DateTime.now(),
                  val: _initVolts.val -
                      voltsDecay(
                        seconds: (DateTime.now()
                            .difference(_initVolts.dateTime)
                            .inSeconds),
                        completedTasks: _completedTasks,
                        startedTasks: _startedTasks,
                        totalTasks: _totalTasks,
                        volts: _initVolts.val,
                      ),
                );
                tempVolts.add(_volts);
                _allVolts = tempVolts;
              });
            }
          }
          return;
        }
    }

    snapshot = await db
        .collection('users')
        .document(_user.uid)
        .collection('dates')
        .where(FieldPath.documentId,
            isGreaterThanOrEqualTo: getDateString(
                DateTime.parse(_date).subtract(Duration(days: decrement))))
        .where(FieldPath.documentId, isLessThanOrEqualTo: _date)
        .getDocuments();
    snapshot.documents.forEach((DocumentSnapshot document) {
      if (mounted) {
        if (document.data != null) {
          document.data['volts'].forEach((volts) {
            setState(() {
              tempVolts.add(Volts(
                  dateTime: DateTime.parse(volts['dateTime']),
                  val: volts['val']));
            });
          });
        }
      }
    });
    userSnapshot = await db.collection('users').document(_user.uid).get();
    if (mounted) {
      setState(() {
        _initVolts = Volts(
          dateTime: DateTime.parse(userSnapshot.data['volts']['dateTime']),
          val: userSnapshot.data['volts']['val'],
        );
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
        tempVolts.add(_volts);
        switch (index) {
          case 0:
            {
              _todayVolts = tempVolts;
              break;
            }
          case 1:
            {
              _weekVolts = tempVolts;
              break;
            }
          case 2:
            {
              _monthVolts = tempVolts;
              break;
            }
        }
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
        switch (_index) {
          case 0:
            {
              if (_todayVolts.isNotEmpty) {
                _voltsDelta = _volts.val - _todayVolts.first.val;
                _todayVolts.last = _volts;
              }
              break;
            }
          case 1:
            {
              if (_weekVolts.isNotEmpty) {
                _voltsDelta = _volts.val - _weekVolts.first.val;
                _weekVolts.last = _volts;
              }
              break;
            }
          case 2:
            {
              if (_monthVolts.isNotEmpty) {
                _voltsDelta = _volts.val - _monthVolts.first.val;
                _monthVolts.last = _volts;
              }
              break;
            }
          case 3:
            {
              if (_allVolts.isNotEmpty) {
                _voltsDelta = _volts.val - _allVolts.first.val;
                _allVolts.last = _volts;
              }
              break;
            }
        }
      });
    }
  }

  Future<void> getOtherStats() async {
    DocumentSnapshot snapshot =
        await db.collection('users').document(_user.uid).get();
    if (mounted) {
      setState(() {
        _avgFocused = Duration(
            seconds:
                snapshot.data['secondsFocused'] ~/ snapshot.data['daysActive']);
        _avgTasks =
            snapshot.data['completedTasks'] ~/ snapshot.data['daysActive'];
      });
    }
  }

  void setText() {
    final quotes = [
      '''“You can waste your lives drawing lines. Or you can live your life crossing them.”''',
      '''“Everything comes to him who hustles while he waits.”''',
      '''"The only difference between ordinary and extraordinary is that little extra."''',
      '''"The secret of getting ahead is getting started."''',
      '''"The way to get started is to quit talking and begin doing."''',
      '''"Don't ask. Act! Action will delineate and define you."''',
      '''“It’s not knowing what to do; it’s doing what you know.”''',
      '''“The big secret in life is that there is no big secret. Whatever your goal, you can get there if you’re willing to work.”''',
      '''“Action is the foundational key to all success.”''',
      '''“Amateurs sit and wait for inspiration, the rest of us just get up and go to work.”''',
    ];
    if (mounted) {
      setState(() {
        if (_totalTasks == 0) {
          _text = quotes[_random.nextInt(quotes.length)];
        } else if (_completedTasks == 0) {
          _text =
              'You have ${_totalTasks.toString() + (_totalTasks == 1 ? ' task' : ' tasks')} today. You got this! 👊';
        } else if (_completedTasks != _totalTasks) {
          switch (_random.nextInt(2)) {
            case 0:
              {
                _text =
                    'You have done ${_completedTasks.toString() + (_completedTasks == 1 ? ' task' : ' tasks')} today. You can do it! 💪';
                break;
              }
            case 1:
              {
                _text =
                    '${(_completedTasks / _tasks.length * 100).round()}% done. Keep up the good work! 🙌';
                break;
              }
          }
        } else {
          switch (_random.nextInt(2)) {
            case 0:
              {
                _text =
                    'You completed ${_completedTasks.toString() + (_completedTasks == 1 ? ' task' : ' tasks')} today. That\'s ${_completedTasks == _avgTasks ? 'the same as' : (_completedTasks - _avgTasks).abs().toString() + ((_completedTasks > _avgTasks) ? ' more' : ' less') + ' than'} your daily average!';
                break;
              }
            case 1:
              {
                _text =
                    'You were Focused for ${_timeFocused.inHours}h ${_timeFocused.inMinutes % 60}m today. That\'s ${_timeFocused.inMinutes == _avgFocused.inMinutes ? 'the same as' : (_timeFocused.inMinutes - _avgFocused.inMinutes).abs().toString() + ((_timeFocused.inMinutes > _avgFocused.inMinutes) ? 'm more' : 'm less') + ' than'} your daily average!';
                break;
              }
          }
        }
      });
    }
  }

  void getData() async {
    _prefs = await SharedPreferences.getInstance();
    _date = getDateString(DateTime.now().subtract(Duration(
        hours: _prefs.getInt('dayStartHour'),
        minutes: _prefs.getInt('dayStartMinute'))));
    await getTasks();
    await getVoltsList();
    updateVolts();
    await getOtherStats();
    setText();
    if (mounted) {
      setState(() {
        _loading = false;
      });
      widget.setLoading(false);
    }
  }

  Widget taskColumn() {
    List<StatsTaskItem> taskTiles = [];
    _tasks.forEach((task) {
      if (task.completed || task.paused) {
        taskTiles.add(StatsTaskItem(task: task));
      }
    });
    if (taskTiles.isEmpty) {
      return Container();
    } else {
      return Padding(
        padding: EdgeInsets.only(left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Column(
              children: taskTiles,
            ),
          ],
        ),
      );
    }
  }

  Widget textButton(BuildContext context,
      {@required int index, @required String text}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        setState(() {
          _index = index;
        });
        await getVoltsList();
        updateVolts();
      },
      child: Container(
        width: 60,
        height: 30,
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
    Future.delayed(loadingDelay, () {
      if (_loading && mounted) {
        widget.setLoading(true);
      }
    });
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
              duration: cardDuration,
              curve: cardCurve,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                    size: 30,
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
                                          size: 14,
                                          color: _volts.val >=
                                                  _todayVolts.first.val
                                              ? Theme.of(context).primaryColor
                                              : Colors.red,
                                        ),
                                        Icon(
                                          FeatherIcons.zap,
                                          size: 14,
                                          color: _volts.val >=
                                                  _todayVolts.first.val
                                              ? Theme.of(context).primaryColor
                                              : Colors.red,
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
                                          _index == 0
                                              ? ' Today'
                                              : _index == 1
                                                  ? ' This Week'
                                                  : _index == 2
                                                      ? ' This Month'
                                                      : ' All Time',
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
                      padding: EdgeInsets.only(top: 50, bottom: 25),
                      child: SizedBox(
                        height: 150,
                        child: _todayVolts.length <= 1
                            ? Container(
                                padding: EdgeInsets.only(left: 80, right: 80),
                                child: Column(
                                  children: [
                                    Text(
                                      'Complete a task to update your Volts.',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text(
                                        'Statistics will be calculated once you complete a task.',
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
                            : VoltsChart(
                                data: _index == 0
                                    ? _todayVolts
                                    : _index == 1
                                        ? _weekVolts
                                        : _index == 2
                                            ? _monthVolts
                                            : _allVolts,
                                id: 'volts'),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 25,
                            right: 25,
                            top: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            duration: cardDuration,
                            curve: cardCurve,
                            left: _index == 0
                                ? 43
                                : _index == 1
                                    ? (SizeConfig.safeBlockHorizontal * 100 -
                                                290) /
                                            3 +
                                        103
                                    : _index == 2
                                        ? (SizeConfig.safeBlockHorizontal *
                                                        100 -
                                                    290) /
                                                3 *
                                                2 +
                                            163
                                        : (SizeConfig.safeBlockHorizontal *
                                                    100 -
                                                290) +
                                            223,
                            bottom: 0,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 50, bottom: 50, left: 25, right: 25),
                      child: Text(
                        _text,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    taskColumn(),
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
