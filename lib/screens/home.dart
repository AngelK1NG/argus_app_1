import 'dart:io' show Platform;
import 'package:Focal/components/task_item.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/local_notifications.dart';
import 'package:Focal/utils/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
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

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const platform = const MethodChannel("com.flutter.lockscreen");

  Timer timer;
  DateTime _startTime;
  String _swatchDisplay = "00:00";
  int _completedTasks;
  int _totalTasks;
  bool _doingTask = false;
  String _date;
  FirebaseUser _user;
  FirestoreProvider _firestoreProvider;
  List<TaskItem> _tasks = [];
  LocalNotificationHelper notificationHelper;
  // StreamSubscription<ScreenStateEvent> _subscription;
  bool _notifConfirmation = false;
  bool _loading = true;
  bool _paused = false;
  int _seconds = 0;
  AnalyticsProvider analyticsProvider = AnalyticsProvider();

  void startTask() async {
    timer = new Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => setState(() {
              if (_doingTask && !_paused) {
                final currentTime = DateTime.now();
                _seconds = (currentTime.difference(_startTime).inSeconds);
                _swatchDisplay = (_seconds ~/ 60).toString().padLeft(2, "0") +
                    ":" +
                    (_seconds % 60).toString().padLeft(2, "0");
              } else {
                timer.cancel();
              }
            }));
    setState(() {
      _doingTask = true;
      _startTime = DateTime.now();
      _paused = false;
    });
    if (Platform.isAndroid) {
      if (await FlutterDnd.isNotificationPolicyAccessGranted) {
        await FlutterDnd.setInterruptionFilter(FlutterDnd
            .INTERRUPTION_FILTER_NONE); // Turn on DND - All notifications are suppressed.
      }
    }
    analyticsProvider.logStartTask(_tasks[0], DateTime.now());
  }

  void stopTask() async {
    setState(() {
      _doingTask = false;
      _swatchDisplay = "00:00";
      _paused = false;
    });
    if (Platform.isAndroid) {
      if (await FlutterDnd.isNotificationPolicyAccessGranted) {
        await FlutterDnd.setInterruptionFilter(FlutterDnd
            .INTERRUPTION_FILTER_ALL); // Turn on DND - All notifications are suppressed.
      }
    }
  }

  void pauseTask() {
    if (_paused) {
      int pausedDifference = _seconds;
      timer = new Timer.periodic(
          const Duration(seconds: 1),
          (Timer timer) => setState(() {
                if (_doingTask && !_paused) {
                  final currentTime = DateTime.now();
                  _seconds = currentTime.difference(_startTime).inSeconds +
                      pausedDifference;
                  _swatchDisplay = (_seconds ~/ 60).toString().padLeft(2, "0") +
                      ":" +
                      (_seconds % 60).toString().padLeft(2, "0");
                } else {
                  timer.cancel();
                }
              }));
      setState(() {
        _doingTask = true;
        _startTime = DateTime.now();
        _paused = !_paused;
      });
      LocalNotificationHelper.paused = false;
    } else {
      setState(() {
        _paused = !_paused;
        LocalNotificationHelper.paused = true;
      });
    }
  }

  void abandonTask() async {
    setState(() {
      _doingTask = false;
      _swatchDisplay = "00:00";
    });
    _firestoreProvider.deleteTask(_date, _tasks[0].id, _tasks[0].completed);
    Fluttertoast.showToast(
      msg: 'Abandoned task: ${_tasks[0].name}',
      backgroundColor: jetBlack,
      textColor: Colors.white,
    );
    if (Platform.isAndroid) {
      if (await FlutterDnd.isNotificationPolicyAccessGranted) {
        await FlutterDnd.setInterruptionFilter(FlutterDnd
            .INTERRUPTION_FILTER_ALL); // Turn on DND - All notifications are suppressed.
      }
    }
    analyticsProvider.logAbandonTask(_tasks[0], DateTime.now(), _swatchDisplay);
  }

  void completeTask(FirebaseUser user) {
    FirestoreProvider firestoreProvider = FirestoreProvider(user);
    TaskItem currentTask = _tasks[0];
    TaskItem finishedTask = TaskItem(
      completed: true,
      name: currentTask.name,
      date: _date,
      order: _tasks.length,
      id: currentTask.id,
      onDismissed: currentTask.onDismissed,
    );
    firestoreProvider.deleteTask(_date, currentTask.id, false);
    _tasks.remove(currentTask);
    firestoreProvider.addTask(finishedTask, _date);
    _tasks.add(finishedTask);
    firestoreProvider.updateTaskOrder(_tasks, _date);
    firestoreProvider.addCompletedTaskNumber(_date);
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date);
    dateDoc.get().then((snapshot) {
      if (snapshot.data == null) {
        dateDoc.setData({
          'secondsSpent': 0,
        });
      }
      dateDoc.updateData({
        'secondsSpent': FieldValue.increment(_seconds),
      });
    });
    analyticsProvider.logCompleteTask(
        finishedTask, DateTime.now(), _swatchDisplay);
  }

  bool areTasksCompleted() {
    for (var task in _tasks) {
      if (!task.completed) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    notificationHelper = LocalNotificationHelper();
    notificationHelper.initialize();
    WidgetsBinding.instance.addObserver(this);
    // startListening();
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
    // _subscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        if (_doingTask) {
          if (Platform.isAndroid) {
            Future.delayed(const Duration(milliseconds: 2000), () {
              FlutterDnd.setInterruptionFilter(
                  FlutterDnd.INTERRUPTION_FILTER_ALL);
              notificationHelper.showNotifications();
              Future.delayed(const Duration(milliseconds: 2500), () {
                FlutterDnd.setInterruptionFilter(
                    FlutterDnd.INTERRUPTION_FILTER_NONE);
              });
            });
          } else {
            printBoi().then((value) {
              if (value) {
                notificationHelper.showNotifications();
              }
            });
          }
        }
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  // void onData(ScreenStateEvent event) {
  //   print(event);
  //   if (event == ScreenStateEvent.SCREEN_OFF) {
  //     LocalNotificationHelper.screenOff = true;
  //   }
  //   if (event == ScreenStateEvent.SCREEN_UNLOCKED) {
  //     LocalNotificationHelper.screenOff = false;
  //   }
  // }

  // void startListening() {
  //   _screen = new Screen();
  //   try {
  //     _subscription = _screen.screenStateStream.listen(onData);
  //   } on ScreenStateException catch (exception) {
  //     print(exception);
  //   }
  // }

  Future<void> showAbandonConfirmationAndroid() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Abandon task?'),
          content: Padding(
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 5,
            ),
            child: Text('Are you sure you want to abandon task?'),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Abandon',
                  style: TextStyle(
                    color: Colors.red,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
                abandonTask();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showAbandonConfirmationIOS() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Abandon task?'),
          content: Padding(
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 5,
            ),
            child: Text('Are you sure you want to abandon task?'),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Abandon',
                  style: TextStyle(
                    color: Colors.red,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
                abandonTask();
              },
            ),
          ],
        );
      },
    );
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

  Future<bool> printBoi() async {
    var value = await platform.invokeMethod("printBoi");
    return value;
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
        backgroundColor:
            _doingTask ? jetBlack : Theme.of(context).primaryColor,
        cardPosition: _doingTask
            ? MediaQuery.of(context).size.height / 2
            : MediaQuery.of(context).size.height / 2 - 100,
        child: StreamBuilder<QuerySnapshot>(
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
                      left: 50,
                      right: 50,
                      bottom: MediaQuery.of(context).size.height / 2 + 180,
                      child: Text(
                        'Good Morning!',
                        textAlign: TextAlign.center,
                        style: topTextStyle,
                      ),
                    ),
                    Positioned(
                      left: 50,
                      right: 50,
                      top: MediaQuery.of(context).size.height / 2,
                      child: Text(
                        'Add a task and start your day!',
                        textAlign: TextAlign.center,
                        style: taskTextStyle,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 120,
                      child: Container(
                        alignment: Alignment.center,
                        child: RctButton(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(context, '/tasks',
                                ModalRoute.withName('/home'));
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
                  String name = task.data['name'];
                  TaskItem actionItem = TaskItem(
                    name: name,
                    id: task.documentID,
                    completed: task.data['completed'],
                    order: task.data['order'],
                    key: UniqueKey(),
                    onDismissed: () {
                      _tasks.remove(_tasks
                          .firstWhere((tasku) => tasku.id == task.documentID));
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
                        left: 50,
                        right: 50,
                        bottom: !_doingTask
                            ? MediaQuery.of(context).size.height / 2 + 180
                            : MediaQuery.of(context).size.height / 2 + 150,
                        child: Text(
                          'Congrats! 🎉',
                          textAlign: TextAlign.center,
                          style: topTextStyle,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: MediaQuery.of(context).size.height / 2 - 33,
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
                        left: 50,
                        right: 50,
                        top: !_doingTask
                            ? MediaQuery.of(context).size.height / 2 - 80
                            : MediaQuery.of(context).size.height / 2 + 20,
                        child: Container(
                          alignment: Alignment.center,
                          height: 117,
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
                        bottom: !_doingTask ? 190 : 90,
                        child: Center(
                          child: RctButton(
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(context,
                                  '/statistics', ModalRoute.withName('/home'));
                            },
                            buttonWidth: 220,
                            colored: true,
                            buttonText: 'Statsistics',
                            textSize: 32,
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: cardSlideDuration,
                        curve: cardSlideCurve,
                        left: 0,
                        right: 0,
                        bottom: !_doingTask ? 130 : 30,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            Navigator.pushNamedAndRemoveUntil(context, '/tasks',
                                ModalRoute.withName('/home'));
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
                          right: 30,
                          bottom: 90,
                          child: Text(
                            ((_totalTasks == null || _totalTasks == 0)
                                        ? 0
                                        : (_completedTasks / _totalTasks) * 100)
                                    .toInt()
                                    .toString() +
                                "%",
                            style: percentTextStyle,
                          )),
                      Positioned(
                        left: 30,
                        right: 30,
                        bottom: 60,
                        child: LinearPercentIndicator(
                          percent: (_totalTasks == null || _totalTasks == 0)
                              ? 0
                              : (_completedTasks / _totalTasks),
                          lineHeight: 20,
                          progressColor: Theme.of(context).accentColor,
                          backgroundColor: Theme.of(context).dividerColor,
                        ),
                      )
                    ],
                  );
                } else {
                  return Stack(
                    children: <Widget>[
                      Positioned(
                          left: 50,
                          right: 50,
                          bottom: MediaQuery.of(context).size.height / 2 + 150,
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
                        bottom: MediaQuery.of(context).size.height / 2 - 33,
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
                        left: 30,
                        right: 30,
                        top: _doingTask
                            ? MediaQuery.of(context).size.height / 2 + 20
                            : MediaQuery.of(context).size.height / 2 - 80,
                        child: Container(
                          alignment: Alignment.center,
                          height: 117,
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
                        bottom: _doingTask ? 90 : 190,
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
                        bottom: _doingTask ? 30 : 130,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            HapticFeedback.heavyImpact();
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
                          right: 30,
                          bottom: 90,
                          child: Visibility(
                            visible: !_doingTask,
                            child: Text(
                              ((_totalTasks == null || _totalTasks == 0)
                                          ? 0
                                          : (_completedTasks / _totalTasks) *
                                              100)
                                      .toInt()
                                      .toString() +
                                  "%",
                              style: percentTextStyle,
                            ),
                          )),
                      Positioned(
                        left: 30,
                        right: 30,
                        bottom: 60,
                        child: Visibility(
                          visible: !_doingTask,
                          child: LinearPercentIndicator(
                            percent: (_totalTasks == null || _totalTasks == 0)
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
      ),
    );
  }
}
