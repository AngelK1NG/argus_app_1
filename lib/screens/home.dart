import 'dart:io' show Platform;
import 'dart:async';
import 'package:Focal/components/task_item.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/local_notifications.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/wrapper.dart';
import '../components/rct_button.dart';
import '../components/sqr_button.dart';
import '../constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const iosChannel = const MethodChannel("com.flutter.lockscreen");
  static const androidChannel = const MethodChannel("plugins.flutter.io/screen");

  Timer timer;
  DateTime _startFocused = DateTime.now();
  DateTime _startPaused = DateTime.now();
  DateTime _startDistracted = DateTime.now();
  String _swatchDisplay = "00:00";
  int _completedTasks;
  int _totalTasks;
  bool _doingTask = false;
  String _date;
  FirebaseUser _user;
  FirestoreProvider _firestoreProvider;
  AnalyticsProvider _analyticsProvider = AnalyticsProvider();
  List<TaskItem> _tasks = [];
  LocalNotificationHelper notificationHelper;
  bool _notifConfirmation = false;
  bool _loading = true;
  bool _paused = false;
  bool _screenOn = true;
  int _seconds = 0;
  int _secondsPaused = 0;
  int _secondsDistracted = 0;
  int _numPaused = 0;
  int _numDistracted = 0;
  int _initSecondsFocused = 0;
  int _initSecondsPaused = 0;
  int _initSecondsDistracted = 0;
  int _initNumPaused = 0;
  int _initNumDistracted = 0;
  ConfettiController _confettiController =
      ConfettiController(duration: Duration(seconds: 1));

  void startTask() async {
    if (Platform.isAndroid) {
      Wakelock.enable();
    }
    _secondsPaused =
        _tasks[0].secondsPaused == null ? 0 : _tasks[0].secondsPaused;
    _initSecondsPaused =
        _tasks[0].secondsPaused == null ? 0 : _tasks[0].secondsPaused;

    _secondsDistracted =
        _tasks[0].secondsDistracted == null ? 0 : _tasks[0].secondsDistracted;
    _initSecondsDistracted =
        _tasks[0].secondsDistracted == null ? 0 : _tasks[0].secondsDistracted;

    _numPaused = _tasks[0].numPaused == null ? 0 : _tasks[0].numPaused;
    _initNumPaused = _tasks[0].numPaused == null ? 0 : _tasks[0].numPaused;

    _numDistracted =
        _tasks[0].numDistracted == null ? 0 : _tasks[0].numDistracted;
    _initNumDistracted =
        _tasks[0].numDistracted == null ? 0 : _tasks[0].numDistracted;

    int initSeconds;
    if (_tasks[0].secondsFocused == null) {
      initSeconds = 0;
    } else if (_tasks[0].secondsDistracted == null) {
      initSeconds = _tasks[0].secondsFocused;
      _initSecondsFocused = _tasks[0].secondsFocused;
    } else {
      initSeconds = _tasks[0].secondsFocused + _tasks[0].secondsDistracted;
      _initSecondsFocused = _tasks[0].secondsFocused;
    }

    timer = new Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => setState(() {
              if (_doingTask && !_paused) {
                final currentTime = DateTime.now();
                _seconds = (currentTime.difference(_startFocused).inSeconds) +
                    initSeconds;
                _swatchDisplay = (_seconds ~/ 60).toString().padLeft(2, "0") +
                    ":" +
                    (_seconds % 60).toString().padLeft(2, "0");
              } else {
                timer.cancel();
              }
            }));
    setState(() {
      _seconds = initSeconds;
      _swatchDisplay = (_seconds ~/ 60).toString().padLeft(2, "0") +
          ":" +
          (_seconds % 60).toString().padLeft(2, "0");
      _doingTask = true;
      _startFocused = DateTime.now();
      _paused = false;
    });
    if (Platform.isAndroid) {
      if (LocalNotificationHelper.dndOn) {
        if (await FlutterDnd.isNotificationPolicyAccessGranted) {
          await FlutterDnd.setInterruptionFilter(
              FlutterDnd.INTERRUPTION_FILTER_NONE);
        }
      }
    }
    _analyticsProvider.logStartTask(_tasks[0], DateTime.now());
  }

  void stopTask() async {
    if (Platform.isAndroid) {
      Wakelock.disable();
    }
    if (_paused) {
      _secondsPaused += DateTime.now().difference(_startPaused).inSeconds;
    }
    setState(() {
      _doingTask = false;
      _paused = false;
    });
    if (Platform.isAndroid) {
      if (LocalNotificationHelper.dndOn) {
        if (await FlutterDnd.isNotificationPolicyAccessGranted) {
          await FlutterDnd.setInterruptionFilter(
              FlutterDnd.INTERRUPTION_FILTER_ALL);
        }
      }
    }
  }

  void pauseTask() {
    if (_paused) {
      int pausedDifference = _seconds;
      _secondsPaused += DateTime.now().difference(_startPaused).inSeconds;
      timer = new Timer.periodic(
          const Duration(seconds: 1),
          (Timer timer) => setState(() {
                if (_doingTask && !_paused) {
                  final currentTime = DateTime.now();
                  _seconds = currentTime.difference(_startFocused).inSeconds +
                      pausedDifference;
                  _swatchDisplay = (_seconds ~/ 60).toString().padLeft(2, "0") +
                      ":" +
                      (_seconds % 60).toString().padLeft(2, "0");
                } else {
                  timer.cancel();
                }
              }));
      setState(() {
        _startFocused = DateTime.now();
        _paused = false;
      });
      LocalNotificationHelper.paused = false;
      _analyticsProvider.logResumeTask(_tasks[0], DateTime.now());
    } else {
      setState(() {
        _startPaused = DateTime.now();
        _paused = true;
        _numPaused++;
        LocalNotificationHelper.paused = true;
      });
      _analyticsProvider.logPauseTask(_tasks[0], DateTime.now());
    }
  }

  void saveTask(FirebaseUser user) async {
    if (Platform.isAndroid) {
      Wakelock.disable();
    }
    TaskItem task = _tasks.removeAt(0);
    task.secondsFocused = _seconds - _secondsDistracted;
    task.secondsDistracted = _secondsDistracted;
    task.secondsPaused = _secondsPaused;
    task.numDistracted = _numDistracted;
    task.numPaused = _numPaused;
    _tasks.insert(_tasks.length - _completedTasks, task);
    _firestoreProvider.updateTaskOrder(_tasks, _date);
    Fluttertoast.showToast(
      msg: '${task.name} has been saved for later',
      backgroundColor: jetBlack,
      textColor: Colors.white,
    );
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date);
    dateDoc.get().then((snapshot) {
      if (snapshot.data == null) {
        dateDoc.setData({
          'secondsFocused': 0,
          'secondsDistracted': 0,
          'secondsPaused': 0,
          'numDistracted': 0,
          'numPaused': 0,
        });
      }
      dateDoc.updateData({
        'secondsFocused': FieldValue.increment(
            _seconds - _secondsDistracted - _initSecondsFocused),
        'secondsDistracted':
            FieldValue.increment(_secondsDistracted - _initSecondsDistracted),
        'secondsPaused':
            FieldValue.increment(_secondsPaused - _initSecondsPaused),
        'numDistracted':
            FieldValue.increment(_numDistracted - _initNumDistracted),
        'numPaused': FieldValue.increment(_numPaused - _initNumPaused),
      }).then((_) {
        _analyticsProvider.logSaveTask(task, DateTime.now());
        _seconds = 0;
        _secondsPaused = 0;
        _secondsDistracted = 0;
        _numPaused = 0;
        _numDistracted = 0;
        _initSecondsFocused = 0;
        _initSecondsPaused = 0;
        _initSecondsDistracted = 0;
        _initNumPaused = 0;
        _initNumDistracted = 0;
      });
    });
  }

  void completeTask(FirebaseUser user) {
    TaskItem currentTask = _tasks[0];
    TaskItem finishedTask = TaskItem(
      completed: true,
      name: currentTask.name,
      date: _date,
      order: _tasks.length,
      id: currentTask.id,
      onDismissed: currentTask.onDismissed,
      secondsFocused: _seconds - _secondsDistracted,
      secondsDistracted: _secondsDistracted,
      secondsPaused: _secondsPaused,
      numDistracted: _numDistracted,
      numPaused: _numPaused,
    );
    _firestoreProvider.deleteTask(_date, currentTask.id, false);
    _tasks.remove(currentTask);
    _firestoreProvider.addTask(finishedTask, _date);
    _tasks.add(finishedTask);
    _firestoreProvider.updateTaskOrder(_tasks, _date);
    _firestoreProvider.addCompletedTaskNumber(_date);
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date);
    dateDoc.get().then((snapshot) {
      if (snapshot.data == null) {
        dateDoc.setData({
          'secondsFocused': 0,
          'secondsDistracted': 0,
          'secondsPaused': 0,
          'numDistracted': 0,
          'numPaused': 0,
        });
      }
      dateDoc.updateData({
        'secondsFocused': FieldValue.increment(
            _seconds - _secondsDistracted - _initSecondsFocused),
        'secondsDistracted':
            FieldValue.increment(_secondsDistracted - _initSecondsDistracted),
        'secondsPaused':
            FieldValue.increment(_secondsPaused - _initSecondsPaused),
        'numDistracted':
            FieldValue.increment(_numDistracted - _initNumDistracted),
        'numPaused': FieldValue.increment(_numPaused - _initNumPaused),
      }).then((_) {
        _analyticsProvider.logSaveTask(finishedTask, DateTime.now());
        _seconds = 0;
        _secondsPaused = 0;
        _secondsDistracted = 0;
        _numPaused = 0;
        _numDistracted = 0;
        _initSecondsFocused = 0;
        _initSecondsPaused = 0;
        _initSecondsDistracted = 0;
        _initNumPaused = 0;
        _initNumDistracted = 0;
      });
    });
    if (areTasksCompleted()) {
      Future.delayed(cardSlideDuration, () {
        _confettiController.play();
      });
    }
  }

  bool areTasksCompleted() {
    for (var task in _tasks) {
      if (!task.completed) {
        return false;
      }
    }
    return true;
  }

  void getSettings() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      LocalNotificationHelper.dndOn = prefs.getBool('do not disturb on') == null
          ? true
          : prefs.getBool('do not disturb on');
      LocalNotificationHelper.notificationsOn =
          prefs.getBool('notifications on') == null
              ? true
              : prefs.getBool('notifications on');
    });
  }

  @override
  void initState() {
    super.initState();
    getSettings();
    notificationHelper = LocalNotificationHelper();
    notificationHelper.initialize();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      _date = getDateString(DateTime.now());
      _user = Provider.of<User>(context, listen: false).user;
      _firestoreProvider = FirestoreProvider(_user);
      DocumentReference dateDoc = db
          .collection('users')
          .document(_user.uid)
          .collection('tasks')
          .document(_date);
      dateDoc.get().then((snapshot) {
        if (snapshot.data == null ||
            snapshot.data['totalTasks'] == null ||
            snapshot.data['completedTasks'] == null) {
          _completedTasks = 0;
          _totalTasks = 0;
          dateDoc.setData({
            'completedTasks': 0,
            'totalTasks': 0,
          }).then((_) {
            dateDoc.snapshots().listen((DocumentSnapshot snapshot) {
              if (mounted) {
                setState(() {
                  _totalTasks = snapshot.data['totalTasks'];
                  _completedTasks = snapshot.data['completedTasks'];
                });
              }
            });
          });
        } else {
          dateDoc.snapshots().listen((DocumentSnapshot snapshot) {
            if (mounted) {
              setState(() {
                _totalTasks = snapshot.data['totalTasks'];
                _completedTasks = snapshot.data['completedTasks'];
              });
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Wakelock.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        if (_doingTask && !_paused) {
          if (Platform.isAndroid) {
            androidScreenOn().then((value) {
              if (value) {
                _startDistracted = DateTime.now();
                _numDistracted++;
                if (LocalNotificationHelper.notificationsOn) {
                  if (LocalNotificationHelper.dndOn) {
                    FlutterDnd.setInterruptionFilter(
                        FlutterDnd.INTERRUPTION_FILTER_ALL);
                    notificationHelper.showNotifications();
                    Future.delayed(const Duration(milliseconds: 3000), () {
                      FlutterDnd.setInterruptionFilter(
                          FlutterDnd.INTERRUPTION_FILTER_NONE);
                    });
                  } else {
                    notificationHelper.showNotifications();
                  }
                }
              }
            });
          } else if (Platform.isIOS) {
            iosScreenOn().then((value) {
              if (value) {
                _startDistracted = DateTime.now();
                _numDistracted++;
                notificationHelper.showNotifications();
                _screenOn = true;
              } else {
                _screenOn = false;
              }
            });
          }
        }
        break;
      case AppLifecycleState.resumed:
        if (!_paused) {
          if (Platform.isIOS) {
            if (_screenOn) {
              _secondsDistracted +=
                  DateTime.now().difference(_startDistracted).inSeconds;
            }
          } else {
            _secondsDistracted +=
                DateTime.now().difference(_startDistracted).inSeconds;
          }
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

// android confirm for notification settings
  Future<void> showNotificationConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Allow do not disturb access'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'This will keep you in focus while you are doing your task. Clicking OK will redirect you to Settings.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                FlutterDnd.gotoPolicySettings();
              },
            ),
          ],
        );
      },
    );
  }

  void checkIfNotificationsOn() async {
    if (Platform.isAndroid) {
      if (await FlutterDnd.isNotificationPolicyAccessGranted == false) {
        if (_notifConfirmation == false) {
          _notifConfirmation = true;
          showNotificationConfirmation();
        }
      }
    }
  }

  Future<bool> iosScreenOn() async {
    var value = await iosChannel.invokeMethod("printBoi");
    return value;
  }

  Future<bool> androidScreenOn() async {
    var value = await androidChannel.invokeMethod("isScreenOn");
    return value;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final TextStyle topTextStyle = TextStyle(
      fontSize: 40,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    final TextStyle swatchTextStyle = TextStyle(
      fontSize: 80,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    final TextStyle taskTextStyle = TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
    );
    final TextStyle secondaryButtonTextStyle = TextStyle(
      fontSize: 22,
      color: Theme.of(context).hintColor,
      fontWeight: FontWeight.w500,
    );
    final TextStyle percentTextStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
    );

    checkIfNotificationsOn();

    return WillPopScope(
      onWillPop: () async => false,
      child: WrapperWidget(
        loading: _loading,
        nav: !_doingTask,
        backgroundColor: _doingTask ? jetBlack : Theme.of(context).primaryColor,
        cardPosition: _doingTask
            ? SizeConfig.safeBlockVertical * 50
            : SizeConfig.safeBlockVertical * 33,
        dynamicChild: Stack(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: db
                    .collection('users')
                    .document(_user.uid)
                    .collection('tasks')
                    .document(_date)
                    .collection('tasks')
                    .orderBy('order')
                    .snapshots(),
                builder: (context, snapshot) {
                  _loading = false;
                  if (!snapshot.hasData ||
                      snapshot.data.documents == null ||
                      snapshot.data.documents.isEmpty) {
                    return Stack(
                      children: <Widget>[
                        Positioned(
                          left: 40,
                          right: 40,
                          top: SizeConfig.safeBlockVertical * 15,
                          child: Text(
                            'Good Morning!',
                            textAlign: TextAlign.center,
                            style: topTextStyle,
                          ),
                        ),
                        Positioned(
                          left: 40,
                          right: 40,
                          top: SizeConfig.safeBlockVertical * 45,
                          child: Container(
                            alignment: Alignment.center,
                            height: SizeConfig.safeBlockVertical * 18,
                            child: Text(
                              'Add a task and start your day!',
                              textAlign: TextAlign.center,
                              style: taskTextStyle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: SizeConfig.safeBlockVertical * 12,
                          child: Container(
                            alignment: Alignment.center,
                            child: RctButton(
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    '/tasks', ModalRoute.withName('/home'));
                              },
                              buttonWidth: 220,
                              colored: true,
                              buttonText: 'Add',
                              textSize: 32,
                            ),
                          ),
                        )
                      ],
                    );
                  } else {
                    _tasks = [];
                    final data = snapshot.data.documents;
                    for (var task in data) {
                      TaskItem actionItem = TaskItem(
                        name: task.data['name'],
                        id: task.documentID,
                        completed: task.data['completed'],
                        order: task.data['order'],
                        secondsFocused: task.data['secondsFocused'],
                        secondsDistracted: task.data['secondsDistracted'],
                        secondsPaused: task.data['secondsPaused'],
                        numDistracted: task.data['numDistracted'],
                        numPaused: task.data['numPaused'],
                        key: UniqueKey(),
                        onDismissed: () {
                          _tasks.remove(_tasks.firstWhere(
                              (tasku) => tasku.id == task.documentID));
                          _firestoreProvider.updateTaskOrder(_tasks, _date);
                        },
                        date: _date,
                      );
                      _tasks.add(actionItem);
                    }
                    if (areTasksCompleted()) {
                      return Stack(
                        children: <Widget>[
                          AnimatedPositioned(
                            duration: cardSlideDuration,
                            curve: cardSlideCurve,
                            left: 40,
                            right: 40,
                            top: SizeConfig.safeBlockVertical * 15,
                            child: Text(
                              'Congrats! 🎉',
                              textAlign: TextAlign.center,
                              style: topTextStyle,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: SizeConfig.safeBlockVertical * 50 - 33,
                            child: AnimatedOpacity(
                              duration: cardSlideDuration,
                              curve: cardSlideCurve,
                              opacity: !_doingTask ? 0 : 1,
                              child: Center(
                                child: SqrButton(
                                  onTap: pauseTask,
                                  icon: _paused
                                      ? Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 32,
                                        )
                                      : Icon(
                                          Icons.pause,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: cardSlideDuration,
                            curve: cardSlideCurve,
                            left: 40,
                            right: 40,
                            top: !_doingTask
                                ? SizeConfig.safeBlockVertical * 40
                                : SizeConfig.safeBlockVertical * 57,
                            child: Container(
                              alignment: Alignment.center,
                              height: SizeConfig.safeBlockVertical * 18,
                              child: Text(
                                'You\'re done!',
                                textAlign: TextAlign.center,
                                style: taskTextStyle,
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: cardSlideDuration,
                            curve: cardSlideCurve,
                            left: 0,
                            right: 0,
                            bottom: !_doingTask
                                ? SizeConfig.safeBlockVertical * 26
                                : SizeConfig.safeBlockVertical * 9,
                            child: Center(
                              child: RctButton(
                                onTap: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/statistics',
                                      ModalRoute.withName('/home'));
                                },
                                buttonWidth: 220,
                                colored: true,
                                buttonText: 'Statistics',
                                textSize: 32,
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: cardSlideDuration,
                            curve: cardSlideCurve,
                            left: 0,
                            right: 0,
                            bottom: !_doingTask
                                ? SizeConfig.safeBlockVertical * 19
                                : SizeConfig.safeBlockVertical * 2,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                Navigator.pushNamedAndRemoveUntil(context,
                                    '/tasks', ModalRoute.withName('/home'));
                              },
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Add another task',
                                  textAlign: TextAlign.center,
                                  style: secondaryButtonTextStyle,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              right: 40,
                              bottom: SizeConfig.safeBlockVertical * 11,
                              child: Text(
                                ((_totalTasks == null || _totalTasks == 0)
                                            ? 0
                                            : (_completedTasks / _totalTasks) *
                                                100)
                                        .toInt()
                                        .toString() +
                                    "%",
                                style: percentTextStyle,
                              )),
                          Positioned(
                            left: 40,
                            right: 40,
                            bottom: SizeConfig.safeBlockVertical * 7,
                            child: LinearPercentIndicator(
                              percent: (_totalTasks == null || _totalTasks == 0)
                                  ? 0
                                  : (_completedTasks / _totalTasks),
                              lineHeight: 20,
                              progressColor: Theme.of(context).accentColor,
                              backgroundColor: Theme.of(context).dividerColor,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Stack(
                        children: <Widget>[
                          Positioned(
                              left: 40,
                              right: 40,
                              top: SizeConfig.safeBlockVertical * 13,
                              child: _doingTask
                                  ? Text(
                                      _swatchDisplay,
                                      textAlign: TextAlign.center,
                                      style: swatchTextStyle,
                                    )
                                  : Text(
                                      'Keep up the good work! 🙌',
                                      textAlign: TextAlign.center,
                                      style: topTextStyle,
                                    )),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: SizeConfig.safeBlockVertical * 50 - 33,
                            child: AnimatedOpacity(
                              duration: cardSlideDuration,
                              curve: cardSlideCurve,
                              opacity: _doingTask ? 1 : 0,
                              child: Center(
                                child: SqrButton(
                                  onTap: pauseTask,
                                  icon: _paused
                                      ? Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 32,
                                        )
                                      : Icon(
                                          Icons.pause,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: cardSlideDuration,
                            curve: cardSlideCurve,
                            left: 40,
                            right: 40,
                            top: !_doingTask
                                ? SizeConfig.safeBlockVertical * 40
                                : SizeConfig.safeBlockVertical * 57,
                            child: Container(
                              alignment: Alignment.center,
                              height: SizeConfig.safeBlockVertical * 18,
                              child: AutoSizeText(
                                _tasks[0].name,
                                textAlign: TextAlign.center,
                                style: taskTextStyle,
                                maxLines: 3,
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: cardSlideDuration,
                            curve: cardSlideCurve,
                            left: 0,
                            right: 0,
                            bottom: !_doingTask
                                ? SizeConfig.safeBlockVertical * 26
                                : SizeConfig.safeBlockVertical * 9,
                            child: Center(
                                child: _doingTask
                                    ? RctButton(
                                        onTap: () async {
                                          setState(() {
                                            _doingTask = false;
                                          });
                                          stopTask();
                                          completeTask(_user);
                                        },
                                        buttonWidth: 220,
                                        colored: true,
                                        buttonText: 'Done',
                                        textSize: 32,
                                      )
                                    : RctButton(
                                        onTap: () async {
                                          setState(() {
                                            _doingTask = true;
                                          });
                                          startTask();
                                        },
                                        buttonWidth: 220,
                                        colored: true,
                                        buttonText: 'Start',
                                        textSize: 32,
                                      )),
                          ),
                          AnimatedPositioned(
                            duration: cardSlideDuration,
                            curve: cardSlideCurve,
                            left: 0,
                            right: 0,
                            bottom: !_doingTask
                                ? SizeConfig.safeBlockVertical * 19
                                : SizeConfig.safeBlockVertical * 2,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                stopTask();
                                saveTask(_user);
                              },
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text('Save for later',
                                    textAlign: TextAlign.center,
                                    style: secondaryButtonTextStyle),
                              ),
                            ),
                          ),
                          Positioned(
                              right: 40,
                              bottom: SizeConfig.safeBlockVertical * 11,
                              child: Visibility(
                                visible: !_doingTask,
                                child: Text(
                                  ((_totalTasks == null || _totalTasks == 0)
                                              ? 0
                                              : (_completedTasks /
                                                      _totalTasks) *
                                                  100)
                                          .toInt()
                                          .toString() +
                                      "%",
                                  style: percentTextStyle,
                                ),
                              )),
                          Positioned(
                            left: 40,
                            right: 40,
                            bottom: SizeConfig.safeBlockVertical * 7,
                            child: Visibility(
                              visible: !_doingTask,
                              child: LinearPercentIndicator(
                                percent:
                                    (_totalTasks == null || _totalTasks == 0)
                                        ? 0
                                        : (_completedTasks / _totalTasks),
                                lineHeight: 20,
                                progressColor: Theme.of(context).accentColor,
                                backgroundColor: Theme.of(context).dividerColor,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  }
                }),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                emissionFrequency: 0.01,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 200,
                particleDrag: 0.03,
                shouldLoop: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
