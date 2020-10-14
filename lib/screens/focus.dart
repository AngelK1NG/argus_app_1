import 'dart:io' show Platform;
import 'dart:async';
import 'dart:math';
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
import '../components/rct_button.dart';
import '../components/sqr_button.dart';
import '../constants.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

class FocusPage extends StatefulWidget {
  final Function goToPage;
  final Function setDoingTask;

  FocusPage({@required this.goToPage, @required this.setDoingTask, Key key})
      : super(key: key);

  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> with WidgetsBindingObserver {
  static const screenChannel = const MethodChannel("plugins.flutter.io/screen");

  Timer _timer;
  DateTime _startFocused = DateTime.now();
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
  LocalNotifications localNotifications;
  SharedPreferences _prefs;
  bool _loading = true;
  bool _saving = false;
  bool _screenOn = true;
  bool _distractionTracking = true;
  bool _distractionTrackingNotice = false;
  int _distractionTrackingNoticeCount = 0;
  int _seconds = 0;
  int _secondsDistracted = 0;
  int _numDistracted = 0;
  int _initSecondsFocused = 0;
  int _initSecondsDistracted = 0;
  int _initNumDistracted = 0;
  ConfettiController _confettiController =
      ConfettiController(duration: Duration(seconds: 1));
  Random _random = Random();
  String _quote;
  String _message;

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
  final messages = [
    'Keep up the good work! 🙌',
    'You got this! 👊',
    'You can do it! 💪',
    'Don\'t forget to hydrate! 💦',
    'Need a break? Take one! 😌'
  ];

  void startTask() async {
    if (!_saving) {
      HapticFeedback.heavyImpact();
      _secondsDistracted =
          _tasks[0].secondsDistracted == null ? 0 : _tasks[0].secondsDistracted;
      _initSecondsDistracted =
          _tasks[0].secondsDistracted == null ? 0 : _tasks[0].secondsDistracted;

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
      _timer = new Timer.periodic(
          const Duration(seconds: 1),
          (Timer timer) => setState(() {
                _seconds =
                    (DateTime.now().difference(_startFocused).inSeconds) +
                        initSeconds;
                _swatchDisplay = (_seconds ~/ 60).toString().padLeft(2, "0") +
                    ":" +
                    (_seconds % 60).toString().padLeft(2, "0");
              }));
      setState(() {
        _startFocused = DateTime.now();
        _seconds =
            (DateTime.now().difference(_startFocused).inSeconds) + initSeconds;
        _swatchDisplay = (_seconds ~/ 60).toString().padLeft(2, "0") +
            ":" +
            (_seconds % 60).toString().padLeft(2, "0");
        _doingTask = true;
      });

      _prefs.setInt('secondsDistracted', _secondsDistracted);
      _prefs.setInt('initSecondsDistracted', _initSecondsDistracted);
      _prefs.setInt('numDistracted', _numDistracted);
      _prefs.setInt('initNumDistracted', _initNumDistracted);
      _prefs.setInt('initSeconds', initSeconds);
      _prefs.setInt('startFocused', _startFocused.millisecondsSinceEpoch);
      _prefs.setString('taskId', _tasks[0].id);
      _prefs.setBool('doingTask', true);

      if (Platform.isAndroid) {
        setDnd(true);
      }
      _analyticsProvider.logStartTask(_tasks[0], DateTime.now());
      widget.setDoingTask(true);
    }
  }

  void stopTask() async {
    setState(() {
      _timer.cancel();
      _saving = true;
      _doingTask = false;
      _quote = quotes[_random.nextInt(quotes.length)];
      _message = messages[_random.nextInt(messages.length)];
      _distractionTracking = true;
      _distractionTrackingNotice = false;
    });
    if (Platform.isAndroid) {
      setDnd(false);
    }
    _prefs.setBool('doingTask', false);
    widget.setDoingTask(false);
  }

  void pauseTask(FirebaseUser user) {
    if (_doingTask) {
      stopTask();
      _tasks[0].secondsFocused = _seconds - _secondsDistracted;
      _tasks[0].secondsDistracted = _secondsDistracted;
      _tasks[0].numPaused =
          _tasks[0].numPaused == null ? 1 : _tasks[0].numPaused + 1;
      _tasks[0].numDistracted = _numDistracted;
      _tasks[0].paused = true;
      _firestoreProvider.updateTasks(_tasks, _date);
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
            'numDistracted': 0,
            'numPaused': 0,
          });
        }
        dateDoc.updateData({
          'secondsFocused': FieldValue.increment(
              _seconds - _secondsDistracted - _initSecondsFocused),
          'secondsDistracted':
              FieldValue.increment(_secondsDistracted - _initSecondsDistracted),
          'numDistracted':
              FieldValue.increment(_numDistracted - _initNumDistracted),
          'numPaused': FieldValue.increment(1),
        }).then((_) {
          _analyticsProvider.logPauseTask(_tasks[0], DateTime.now());
          _seconds = 0;
          _secondsDistracted = 0;
          _numDistracted = 0;
          _initSecondsFocused = 0;
          _initSecondsDistracted = 0;
          _initNumDistracted = 0;
          _saving = false;
        });
      });
    }
  }

  void completeTask(FirebaseUser user) {
    if (_doingTask) {
      stopTask();
      TaskItem task = _tasks.removeAt(0);
      task.secondsFocused = _seconds - _secondsDistracted;
      task.secondsDistracted = _secondsDistracted;
      task.numDistracted = _numDistracted;
      task.numPaused = task.numPaused == null ? 0 : task.numPaused;
      task.completed = true;
      _tasks.add(task);
      _firestoreProvider.updateTasks(_tasks, _date);
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
            'numDistracted': 0,
            'numPaused': 0,
          });
        }
        dateDoc.updateData({
          'secondsFocused': FieldValue.increment(
              _seconds - _secondsDistracted - _initSecondsFocused),
          'secondsDistracted':
              FieldValue.increment(_secondsDistracted - _initSecondsDistracted),
          'numDistracted':
              FieldValue.increment(_numDistracted - _initNumDistracted),
        }).then((_) {
          _analyticsProvider.logCompleteTask(task, DateTime.now());
          _seconds = 0;
          _secondsDistracted = 0;
          _numDistracted = 0;
          _initSecondsFocused = 0;
          _initSecondsDistracted = 0;
          _initNumDistracted = 0;
          _saving = false;
        });
      });
      if (areTasksCompleted()) {
        Future.delayed(cardSlideDuration, () {
          _confettiController.play();
        });
      }
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

  void getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getBool('repeatDistractedNotification') == null) {
      _prefs.setBool('repeatDistractedNotification', true);
    }
    if (_prefs.getBool('focusDnd') == null) {
      _prefs.setBool('focusDnd', true);
    }
    if (_prefs.getBool('doingTask') == true) {
      db
          .collection('users')
          .document(_user.uid)
          .collection('tasks')
          .document(_date)
          .collection('tasks')
          .where('order', isEqualTo: 1)
          .getDocuments()
          .then((snapshot) async {
        if (snapshot == null ||
            snapshot.documents == null ||
            snapshot.documents.isEmpty ||
            snapshot.documents[0].documentID != _prefs.getString('taskId')) {
          setState(() {
            _doingTask = false;
          });
          _prefs.setBool('doingTask', false);
        } else {
          _secondsDistracted = _prefs.getInt('secondsDistracted');
          _initSecondsDistracted = _prefs.getInt('initSecondsDistracted');
          _numDistracted = _prefs.getInt('numDistracted');
          _initNumDistracted = _prefs.getInt('initNumDistracted');
          int initSeconds = _prefs.getInt('initSeconds');
          _timer = new Timer.periodic(
              const Duration(seconds: 1),
              (Timer timer) => setState(() {
                    _seconds =
                        (DateTime.now().difference(_startFocused).inSeconds) +
                            initSeconds;
                    _swatchDisplay =
                        (_seconds ~/ 60).toString().padLeft(2, "0") +
                            ":" +
                            (_seconds % 60).toString().padLeft(2, "0");
                  }));
          setState(() {
            _startFocused = DateTime.fromMillisecondsSinceEpoch(
                _prefs.getInt('startFocused'));
            _seconds = (DateTime.now().difference(_startFocused).inSeconds) +
                initSeconds;
            _swatchDisplay = (_seconds ~/ 60).toString().padLeft(2, "0") +
                ":" +
                (_seconds % 60).toString().padLeft(2, "0");
            _doingTask = true;
          });
          if (_prefs.getBool('distracted')) {
            _startDistracted = DateTime.fromMillisecondsSinceEpoch(
                _prefs.getInt('startDistracted'));
            _secondsDistracted +=
                DateTime.now().difference(_startDistracted).inSeconds;
            _numDistracted++;
            _prefs.setInt('secondsDistracted', _secondsDistracted);
            _prefs.setInt('numDistracted', _numDistracted);
            _prefs.setBool('distracted', false);
          }
          widget.setDoingTask(true);
        }
      });
    } else {
      setState(() {
        _doingTask = false;
      });
    }
  }

  void setDnd(bool on) async {
    if (_prefs.getBool('focusDnd')) {
      if (on) {
        if (await FlutterDnd.isNotificationPolicyAccessGranted) {
          await FlutterDnd.setInterruptionFilter(
              FlutterDnd.INTERRUPTION_FILTER_NONE);
        }
      } else {
        if (await FlutterDnd.isNotificationPolicyAccessGranted) {
          await FlutterDnd.setInterruptionFilter(
              FlutterDnd.INTERRUPTION_FILTER_ALL);
        }
      }
    }
  }

  Future<void> showDndConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Allow Do Not Disturb access'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'This will help maintain your focus while you are doing your task. Clicking Ok will redirect you to Settings.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Turn off',
                  style: TextStyle(
                    color: Colors.red,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
                _prefs.setBool('focusDnd', false);
              },
            ),
            FlatButton(
              child: Text('Ok'),
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

  void checkIfDndOn() async {
    if (Platform.isAndroid) {
      if (await FlutterDnd.isNotificationPolicyAccessGranted == false) {
        if (_prefs.getBool('focusDnd')) {
          showDndConfirmation();
        }
      }
    }
  }

  Future<bool> iosScreenOn() async {
    var value = await screenChannel.invokeMethod("isScreenOn");
    return value;
  }

  Future<bool> androidScreenOn() async {
    var value = await screenChannel.invokeMethod("isScreenOn");
    return value;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getPrefs();
    checkIfDndOn();
    localNotifications = LocalNotifications();
    localNotifications.initialize();
    localNotifications.cancelDistractedNotification();
    setState(() {
      _quote = quotes[_random.nextInt(quotes.length)];
      _message = messages[_random.nextInt(messages.length)];
      _date = getDateString(DateTime.now());
      _user = Provider.of<User>(context, listen: false).user;
      _firestoreProvider = FirestoreProvider(_user);
      DocumentReference dateDoc = db
          .collection('users')
          .document(_user.uid)
          .collection('tasks')
          .document(_date);
      dateDoc.get().then((snapshot) {
        if (snapshot.data == null) {
          dateDoc.setData({
            'completedTasks': 0,
            'totalTasks': 0,
            'secondsFocused': 0,
            'secondsDistracted': 0,
            'numDistracted': 0,
            'numPaused': 0,
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        {
          if (_doingTask && _distractionTracking) {
            if (Platform.isAndroid) {
              androidScreenOn().then((value) {
                if (value) {
                  _startDistracted = DateTime.now();
                  _prefs.setInt('startDistracted',
                      _startDistracted.millisecondsSinceEpoch);
                  _prefs.setBool('distracted', true);
                  _screenOn = true;
                  localNotifications.distractedNotification();
                  setDnd(false);
                } else {
                  _screenOn = false;
                }
              });
            } else if (Platform.isIOS) {
              iosScreenOn().then((value) {
                if (value) {
                  _startDistracted = DateTime.now();
                  _prefs.setBool('distracted', true);
                  localNotifications.distractedNotification();
                  _screenOn = true;
                } else {
                  _screenOn = false;
                }
              });
            }
          }
          break;
        }
      case AppLifecycleState.resumed:
        {
          if (_screenOn && _distractionTracking && _doingTask) {
            _secondsDistracted +=
                DateTime.now().difference(_startDistracted).inSeconds;
            _numDistracted++;
            _prefs.setInt('secondsDistracted', _secondsDistracted);
            _prefs.setInt('numDistracted', _numDistracted);
            _prefs.setBool('distracted', false);
            setDnd(true);
            localNotifications.cancelDistractedNotification();
          } else if (_distractionTracking == false) {
            setState(() {
              _distractionTracking = true;
            });
          }
          break;
        }
      case AppLifecycleState.inactive:
        {
          break;
        }
      case AppLifecycleState.detached:
        {
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return WillPopScope(
      onWillPop: () async => false,
      child: AnimatedOpacity(
        opacity: _loading ? 0 : 1,
        duration: loadingDuration,
        curve: loadingCurve,
        child: Stack(
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
                  Future.delayed(cardSlideDuration, () {
                    if (mounted) {
                      setState(() {
                        _loading = false;
                      });
                    }
                  });
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
                            TimeOfDay.now().hour < 13
                                ? 'Good Morning!'
                                : TimeOfDay.now().hour < 18
                                    ? 'Good Afternoon!'
                                    : 'Good Evening!',
                            textAlign: TextAlign.center,
                            style: topTextStyle,
                          ),
                        ),
                        Positioned(
                          left: 40,
                          right: 40,
                          top: SizeConfig.safeBlockVertical * 42,
                          child: Container(
                            alignment: Alignment.center,
                            height: SizeConfig.safeBlockVertical * 20,
                            child: AutoSizeText(
                              _quote,
                              textAlign: TextAlign.center,
                              style: taskTextStyle,
                              maxLines: 4,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: SizeConfig.safeBlockVertical * 70,
                          child: Container(
                            alignment: Alignment.center,
                            child: RctButton(
                              onTap: () {
                                widget.goToPage(1);
                              },
                              buttonWidth: 220,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).accentColor
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              buttonText: 'Add Task',
                              textSize: 32,
                              vibrate: true,
                            ),
                          ),
                        )
                      ],
                    );
                  } else {
                    _tasks = [];
                    final data = snapshot.data.documents;
                    for (var task in data) {
                      TaskItem newTask = TaskItem(
                        name: task.data['name'],
                        id: task.documentID,
                        completed: task.data['completed'],
                        paused: task.data['paused'] == null
                            ? false
                            : task.data['paused'],
                        order: task.data['order'],
                        secondsFocused: task.data['secondsFocused'],
                        secondsDistracted: task.data['secondsDistracted'],
                        numDistracted: task.data['numDistracted'],
                        numPaused: task.data['numPaused'],
                        key: UniqueKey(),
                        date: _date,
                      );
                      _tasks.add(newTask);
                    }
                    if (areTasksCompleted()) {
                      return Stack(
                        children: <Widget>[
                          Positioned(
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
                            top: SizeConfig.safeBlockVertical * 50 - 30,
                            child: AnimatedOpacity(
                              duration: cardSlideDuration,
                              curve: cardSlideCurve,
                              opacity: !_doingTask ? 0 : 1,
                              child: Center(
                                child: SqrButton(
                                  onTap: () => pauseTask(_user),
                                  icon: Icon(
                                    Icons.pause,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).accentColor
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  vibrate: true,
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
                                ? SizeConfig.safeBlockVertical * 42
                                : SizeConfig.safeBlockVertical * 56,
                            child: Container(
                              alignment: Alignment.center,
                              height: SizeConfig.safeBlockVertical * 20,
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
                            top: !_doingTask
                                ? SizeConfig.safeBlockVertical * 70
                                : SizeConfig.safeBlockVertical * 84,
                            child: Center(
                              child: RctButton(
                                onTap: () {
                                  widget.goToPage(2);
                                },
                                buttonWidth: 220,
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).accentColor
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                buttonText: 'Statistics',
                                textSize: 32,
                                vibrate: true,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Stack(
                        children: <Widget>[
                          Positioned(
                            left: 20,
                            top: 20,
                            child: Offstage(
                              offstage: !_doingTask,
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.heavyImpact();
                                  if (_distractionTracking) {
                                    setState(() {
                                      _distractionTracking = false;
                                      _distractionTrackingNotice = true;
                                      _distractionTrackingNoticeCount++;
                                    });
                                    final distractionTrackingNoticeCount =
                                        _distractionTrackingNoticeCount;
                                    Future.delayed(Duration(milliseconds: 4000),
                                        () {
                                      if (mounted) {
                                        if (_distractionTrackingNoticeCount ==
                                            distractionTrackingNoticeCount) {
                                          setState(() {
                                            _distractionTrackingNotice = false;
                                          });
                                        }
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      _distractionTracking = true;
                                      _distractionTrackingNotice = false;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Icon(
                                      FeatherIcons.logOut,
                                      color: _distractionTracking
                                          ? Colors.white
                                          : Colors.red,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 40,
                            right: 40,
                            top: SizeConfig.safeBlockVertical * 12,
                            child: _doingTask
                                ? Stack(
                                    children: <Widget>[
                                      AnimatedOpacity(
                                        opacity:
                                            _distractionTrackingNotice ? 0 : 1,
                                        duration: loadingDuration,
                                        curve: loadingCurve,
                                        child: Center(
                                          child: Text(
                                            _swatchDisplay,
                                            textAlign: TextAlign.center,
                                            style: swatchTextStyle,
                                          ),
                                        ),
                                      ),
                                      AnimatedOpacity(
                                        opacity:
                                            _distractionTrackingNotice ? 1 : 0,
                                        duration: loadingDuration,
                                        curve: loadingCurve,
                                        child: Container(
                                          alignment: Alignment.center,
                                          height:
                                              SizeConfig.safeBlockVertical * 20,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                'Distraction tracking is off',
                                                textAlign: TextAlign.center,
                                                style: topTextStyle,
                                              ),
                                              Text(
                                                'You can now leave the app',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    height: SizeConfig.safeBlockVertical * 15,
                                    child: AutoSizeText(
                                      _totalTasks != null &&
                                              _completedTasks != null &&
                                              _totalTasks - _completedTasks == 1
                                          ? 'Almost there! Keep pushing 👊'
                                          : _message,
                                      textAlign: TextAlign.center,
                                      style: topTextStyle,
                                      maxLines: 2,
                                    ),
                                  ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: SizeConfig.safeBlockVertical * 50 - 30,
                            child: AnimatedOpacity(
                              duration: cardSlideDuration,
                              curve: cardSlideCurve,
                              opacity: _doingTask ? 1 : 0,
                              child: Center(
                                child: SqrButton(
                                  onTap: () => pauseTask(_user),
                                  icon: Icon(
                                    Icons.pause,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  gradient: LinearGradient(
                                    colors: _distractionTracking
                                        ? [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context).accentColor
                                          ]
                                        : [darkRed, Colors.red],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  vibrate: true,
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
                                ? SizeConfig.safeBlockVertical * 42
                                : SizeConfig.safeBlockVertical * 56,
                            child: Container(
                              alignment: Alignment.center,
                              height: SizeConfig.safeBlockVertical * 20,
                              child: AutoSizeText(
                                _tasks[0].name,
                                textAlign: TextAlign.center,
                                style: taskTextStyle,
                                maxLines: 4,
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: cardSlideDuration,
                            curve: cardSlideCurve,
                            left: 0,
                            right: 0,
                            top: !_doingTask
                                ? SizeConfig.safeBlockVertical * 70
                                : SizeConfig.safeBlockVertical * 84,
                            child: Center(
                                child: _doingTask
                                    ? RctButton(
                                        onTap: () {
                                          if (_distractionTracking) {
                                            completeTask(_user);
                                          } else {
                                            setState(() {
                                              _distractionTracking = true;
                                              _distractionTrackingNotice =
                                                  false;
                                            });
                                          }
                                        },
                                        buttonWidth: 220,
                                        gradient: LinearGradient(
                                          colors: _distractionTracking
                                              ? [
                                                  Theme.of(context)
                                                      .primaryColor,
                                                  Theme.of(context).accentColor
                                                ]
                                              : [darkRed, Colors.red],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        buttonText: _distractionTracking
                                            ? 'Done'
                                            : 'Cancel',
                                        textSize: 32,
                                        vibrate: true,
                                      )
                                    : RctButton(
                                        onTap: () {
                                          startTask();
                                        },
                                        buttonWidth: 220,
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context).accentColor
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        buttonText: _tasks[0].paused
                                            ? 'Resume'
                                            : 'Start',
                                        textSize: 32,
                                        vibrate: false,
                                      )),
                          ),
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
