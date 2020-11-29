import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:flutter/services.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/sqr_button.dart';
import 'package:Focal/components/task_item.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Focal/components/volts.dart';

class TasksPage extends StatefulWidget {
  final Function goToPage;
  final Function setLoading;

  TasksPage({
    @required this.goToPage,
    @required this.setLoading,
    Key key,
  }) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _formKey = GlobalKey<FormState>();
  SharedPreferences _prefs;
  FocusNode _focus = FocusNode();
  DateTime _date = DateTime.now();
  FirebaseUser _user;
  FirestoreProvider _firestoreProvider;
  bool _loading = true;
  bool _dateLoading = true;
  bool _addingTask = false;
  bool _keyboard = false;
  List<TaskItem> _tasks = [];
  List<TaskItem> _tmrTasks = [];
  int _completedTasks = 0;
  int _todayStartedTasks = 0;
  int _todayTotalTasks = 0;
  String _dateString = 'Today';
  String _secondaryDateString;
  DateTime _today;
  DateTime _yesterday;
  DateTime _tomorrow;
  Volts _initVolts;
  List<Volts> _todayVolts = [];

  void deferTask(TaskItem task) {
    final date = _date;
    final tasks = _tasks;
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    setVolts();
    setState(() {
      _tasks.remove(_tasks.firstWhere((tasku) => tasku.id == task.id));
      if (task.completed) {
        _completedTasks--;
      }
    });
    updateTaskOrder();
    firestoreProvider.deleteTask(task, getDateString(_date));
    firestoreProvider.updateTasks(_tasks, getDateString(_date));
    DateTime tomorrow = _date.add(Duration(days: 1));
    _tmrTasks = [];
    int completedTasks = 0;
    FirebaseUser user = context.read<User>().user;
    db
        .collection('users')
        .document(user.uid)
        .collection('dates')
        .document(getDateString(tomorrow))
        .collection('tasks')
        .orderBy('order')
        .getDocuments()
        .then((snapshot) async {
      snapshot.documents.forEach((task) {
        String name = task.data['name'];
        TaskItem newTask = TaskItem(
          name: name,
          id: task.documentID,
          completed: task.data['completed'],
          paused: task.data['paused'] == null ? false : task.data['paused'],
          order: task.data['order'],
          secondsFocused: task.data['secondsFocused'],
          secondsDistracted: task.data['secondsDistracted'],
          numDistracted: task.data['numDistracted'],
          numPaused: task.data['numPaused'],
          voltsIncrement: task.data['voltsIncrement'],
          key: UniqueKey(),
          date: getDateString(tomorrow),
        );
        _tmrTasks.add(newTask);
        if (newTask.completed) {
          completedTasks++;
        }
      });
      _tmrTasks.insert(_tmrTasks.length - completedTasks, task);
      _tmrTasks[_tmrTasks.length - completedTasks - 1].id =
          await firestoreProvider.addTask(task, getDateString(tomorrow));
      firestoreProvider.updateTasks(_tmrTasks, getDateString(tomorrow));
      Scaffold.of(context).showSnackBar(SnackBar(
        padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
        content: Text('Deferred "' + task.name + '" to tomorrow'),
        duration: snackbarDuration,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            setVolts();
            _tmrTasks
                .remove(_tmrTasks.firstWhere((tasku) => tasku.id == task.id));
            firestoreProvider.deleteTask(task, getDateString(tomorrow));
            firestoreProvider.updateTasks(_tmrTasks, getDateString(tomorrow));
            if (mounted) {
              if (date == _date) {
                setState(() {
                  _tasks.insert(task.order - 1, task);
                  if (task.completed) {
                    _completedTasks++;
                  }
                });
                updateTaskOrder();
                await firestoreProvider.addTask(task, getDateString(_date));
                firestoreProvider.updateTasks(_tasks, getDateString(_date));
              } else {
                tasks.insert(task.order - 1, task);
                await firestoreProvider.addTask(task, getDateString(date));
                firestoreProvider.updateTasks(tasks, getDateString(date));
                getTasks();
              }
            } else {
              tasks.insert(task.order - 1, task);
              await firestoreProvider.addTask(task, getDateString(date));
              firestoreProvider.updateTasks(tasks, getDateString(date));
            }
          },
        ),
      ));
    });
  }

  void deleteTask(TaskItem task) {
    final date = _date;
    final tasks = _tasks;
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    setVolts();
    setState(() {
      _tasks.remove(_tasks.firstWhere((tasku) => tasku.id == task.id));
      if (task.completed) {
        _completedTasks--;
      }
    });
    updateTaskOrder();
    firestoreProvider.deleteTask(task, getDateString(_date));
    firestoreProvider.updateTasks(_tasks, getDateString(_date));
    Scaffold.of(context).showSnackBar(SnackBar(
      padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
      content: Text('Deleted "' + task.name + '"'),
      duration: snackbarDuration,
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          setVolts();
          if (mounted) {
            if (date == getDateString(_date)) {
              setState(() {
                _tasks.insert(task.order - 1, task);
                if (task.completed) {
                  _completedTasks++;
                }
              });
              updateTaskOrder();
              await firestoreProvider.addTask(task, getDateString(_date));
              firestoreProvider.updateTasks(_tasks, getDateString(_date));
            } else {
              tasks.insert(task.order - 1, task);
              await firestoreProvider.addTask(task, getDateString(date));
              firestoreProvider.updateTasks(tasks, getDateString(date));
              getTasks();
            }
          } else {
            tasks.insert(task.order - 1, task);
            await firestoreProvider.addTask(task, getDateString(date));
            firestoreProvider.updateTasks(tasks, getDateString(date));
          }
        },
      ),
    ));
  }

  void setVolts() async {
    final dateToCheck = DateTime(_date.year, _date.month, _date.day);
    if (dateToCheck == _today && _todayVolts.isNotEmpty) {
      _todayVolts.add(Volts(
        dateTime: DateTime.now(),
        val: _initVolts.val -
            voltsDecay(
              seconds: DateTime.now().difference(_initVolts.dateTime).inSeconds,
              completedTasks: _completedTasks,
              startedTasks: _todayStartedTasks,
              totalTasks: _todayTotalTasks,
              volts: _initVolts.val,
            ),
      ));
      _initVolts = _todayVolts.last;
      List<Map> newVolts = [];
      _todayVolts.forEach((volts) {
        newVolts.add(
            {'dateTime': getDateTimeString(volts.dateTime), 'val': volts.val});
      });
      db.collection('users').document(_user.uid).updateData({
        'volts': newVolts.last,
      });
      db
          .collection('users')
          .document(_user.uid)
          .collection('dates')
          .document(getDateString(_date))
          .updateData({
        'volts': newVolts,
      });
    }
  }

  Future<void> getTasks() async {
    _tasks = [];
    _completedTasks = 0;
    FirebaseUser user = context.read<User>().user;
    QuerySnapshot snapshot = await db
        .collection('users')
        .document(user.uid)
        .collection('dates')
        .document(getDateString(_date))
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
          paused: task.data['paused'] == null ? false : task.data['paused'],
          order: task.data['order'],
          date: getDateString(_date),
          secondsFocused: task.data['secondsFocused'],
          secondsDistracted: task.data['secondsDistracted'],
          numDistracted: task.data['numDistracted'],
          numPaused: task.data['numPaused'],
          voltsIncrement: task.data['voltsIncrement'],
          key: UniqueKey(),
        );
        newTask.onDismissed = (direction) {
          if (direction == DismissDirection.startToEnd) {
            deferTask(newTask);
            AnalyticsProvider().logDeferTask(newTask, DateTime.now());
          } else {
            deleteTask(newTask);
            AnalyticsProvider().logDeleteTask(newTask, DateTime.now());
          }
        };
        newTask.onUpdate = (value) => newTask.name = value;
        setState(() {
          _tasks.add(newTask);
          if (newTask.completed) {
            _completedTasks++;
          }
        });
      });
    }
  }

  Future<void> getVolts() async {
    DocumentReference userDoc = db.collection('users').document(_user.uid);
    DocumentSnapshot userSnapshot = await userDoc.get();
    if (userSnapshot.data != null) {
      _initVolts = Volts(
          dateTime: DateTime.parse(userSnapshot.data['volts']['dateTime']),
          val: userSnapshot.data['volts']['val']);
    }
    DocumentReference dateDoc = db
        .collection('users')
        .document(_user.uid)
        .collection('dates')
        .document(getDateString(_date));
    DocumentSnapshot dateSnapshot = await dateDoc.get();
    if (dateSnapshot.data != null) {
      dateSnapshot.data['volts'].forEach((volts) {
        _todayVolts.add(Volts(
            dateTime: DateTime.parse(volts['dateTime']), val: volts['val']));
      });
      _todayStartedTasks = dateSnapshot.data['startedTasks'];
      _todayTotalTasks = dateSnapshot.data['totalTasks'];
    }
  }

  void setDate(DateTime date) async {
    setState(() {
      _loading = true;
      _date = date;
      DateTime today = DateTime.now().subtract(Duration(
        hours: _prefs.getInt('dayStartHour'),
        minutes: _prefs.getInt('dayStartMinute'),
      ));
      _today = DateTime(today.year, today.month, today.day);
      _yesterday = DateTime(today.year, today.month, today.day - 1);
      _tomorrow = DateTime(today.year, today.month, today.day + 1);
      final dateToCheck = DateTime(date.year, date.month, date.day);
      if (dateToCheck == _today) {
        _dateString = 'Today';
      } else if (dateToCheck == _yesterday) {
        _dateString = 'Yesterday';
      } else if (dateToCheck == _tomorrow) {
        _dateString = 'Tomorrow';
      } else {
        switch (date.weekday) {
          case 1:
            {
              _dateString = 'Monday';
              break;
            }
          case 2:
            {
              _dateString = 'Tuesday';
              break;
            }
          case 3:
            {
              _dateString = 'Wednesday';
              break;
            }
          case 4:
            {
              _dateString = 'Thursday';
              break;
            }
          case 5:
            {
              _dateString = 'Friday';
              break;
            }
          case 6:
            {
              _dateString = 'Saturday';
              break;
            }
          case 7:
            {
              _dateString = 'Sunday';
              break;
            }
        }
      }
      if ((dateToCheck == _today) ||
          (dateToCheck == _yesterday) ||
          (dateToCheck == _tomorrow)) {
        switch (date.weekday) {
          case 1:
            {
              _secondaryDateString =
                  'Mon ' + date.month.toString() + '/' + date.day.toString();
              break;
            }
          case 2:
            {
              _secondaryDateString =
                  'Tue ' + date.month.toString() + '/' + date.day.toString();
              break;
            }
          case 3:
            {
              _secondaryDateString =
                  'Wed ' + date.month.toString() + '/' + date.day.toString();
              break;
            }
          case 4:
            {
              _secondaryDateString =
                  'Thu ' + date.month.toString() + '/' + date.day.toString();
              break;
            }
          case 5:
            {
              _secondaryDateString =
                  'Fri ' + date.month.toString() + '/' + date.day.toString();
              break;
            }
          case 6:
            {
              _secondaryDateString =
                  'Sat ' + date.month.toString() + '/' + date.day.toString();
              break;
            }
          case 7:
            {
              _secondaryDateString =
                  'Sun ' + date.month.toString() + '/' + date.day.toString();
              break;
            }
        }
      } else {
        _secondaryDateString =
            date.month.toString() + '/' + date.day.toString();
      }
    });
    await getTasks();
    await getVolts();
    if (mounted) {
      setState(() {
        _loading = false;
      });
      widget.setLoading(false);
    }
  }

  void setToday() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getBool('newUser') == true) {
      await _firestoreProvider.addDefaultTasks();
      _prefs.setBool('newUser', false);
    }
    setDate(DateTime.now().subtract(Duration(
      hours: _prefs.getInt('dayStartHour'),
      minutes: _prefs.getInt('dayStartMinute'),
    )));
    setState(() => _dateLoading = false);
  }

  void updateTaskOrder() {
    for (TaskItem task in _tasks) {
      task.order = _tasks.indexOf(task) + 1;
    }
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
    _firestoreProvider = FirestoreProvider(_user);
    setToday();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          _keyboard = visible;
        });
        if (!visible) {
          FocusScope.of(context).unfocus();
          setState(() {
            _addingTask = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle dateTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
    TextStyle todayTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).primaryColor,
    );
    return WillPopScope(
      onWillPop: () => widget.goToPage(0),
      child: Stack(children: <Widget>[
        Visibility(
          visible: !_dateLoading,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 10,
                child: Center(
                  child: Text(
                    _secondaryDateString == null ? '' : _secondaryDateString,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 5,
                right: 5,
                top: 5,
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx > 50) {
                      setDate(_date.add(Duration(days: -1)));
                      FocusScope.of(context).unfocus();
                    }
                    if (details.velocity.pixelsPerSecond.dx < -50) {
                      setDate(_date.add(Duration(days: 1)));
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setDate(_date.add(Duration(days: -1)));
                            FocusScope.of(context).unfocus();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (DateTime(
                                          _date.year, _date.month, _date.day) ==
                                      _tomorrow)
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Center(
                              child: Text(
                                  _date.add(Duration(days: -1)).day.toString(),
                                  style: (DateTime(_date.year, _date.month,
                                              _date.day) ==
                                          _tomorrow)
                                      ? todayTextStyle
                                      : dateTextStyle),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2120),
                            ).then((date) {
                              if (date != null) {
                                setDate(date);
                              }
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                _dateString,
                                style: headerTextStyle,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setDate(_date.add(Duration(days: 1)));
                            FocusScope.of(context).unfocus();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (DateTime(
                                          _date.year, _date.month, _date.day) ==
                                      _yesterday)
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Center(
                              child: Text(
                                  _date.add(Duration(days: 1)).day.toString(),
                                  style: (DateTime(_date.year, _date.month,
                                              _date.day) ==
                                          _yesterday)
                                      ? todayTextStyle
                                      : dateTextStyle),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: cardDuration,
          curve: cardCurve,
          child: Opacity(
            opacity: _loading ? 0 : 1,
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: 28,
                  left: 28,
                  top: 80,
                  child: Offstage(
                    offstage: _tasks.length == 0,
                    child: Container(
                      height: 55,
                      alignment: Alignment.center,
                      child: Text(
                        ((_tasks.length == null || _tasks.length == 0)
                                ? '0'
                                : (_completedTasks / _tasks.length * 100)
                                    .round()
                                    .toString()) +
                            '% completed',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 80,
                  left: 80,
                  top: SizeConfig.safeBlockVertical * 45,
                  child: Offstage(
                    offstage: _tasks.length != 0,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Start fresh.',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              'Got something to do? Add it by tapping the + button.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  left: 0,
                  top: 135,
                  child: SizedBox(
                    height: _keyboard
                        ? SizeConfig.safeBlockVertical * 100 -
                            MediaQuery.of(context).viewInsets.bottom -
                            135
                        : SizeConfig.safeBlockVertical * 100 - 215,
                    child: ReorderableListView(
                      padding: EdgeInsets.all(0),
                      onReorder: ((oldIndex, newIndex) {
                        if (!_tasks[oldIndex].completed) {
                          List<TaskItem> tasks = _tasks;
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final task = tasks.removeAt(oldIndex);
                          if (newIndex >= tasks.length - _completedTasks) {
                            int distanceFromEnd = tasks.length - newIndex;
                            tasks.insert(
                                newIndex - (_completedTasks - distanceFromEnd),
                                task);
                            _firestoreProvider.updateTasks(
                                tasks, getDateString(_date));
                          } else {
                            tasks.insert(newIndex, task);
                            _firestoreProvider.updateTasks(
                                tasks, getDateString(_date));
                          }
                          updateTaskOrder();
                        }
                      }),
                      children: _tasks,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: keyboardDuration,
                  curve: keyboardCurve,
                  bottom: _addingTask
                      ? MediaQuery.of(context).viewInsets.bottom - 75
                      : -150,
                  left: 0,
                  right: 0,
                  child: Offstage(
                    offstage: !_addingTask,
                    child: AnimatedContainer(
                      duration: cardDuration,
                      curve: cardCurve,
                      height: 150,
                      width: SizeConfig.safeBlockHorizontal * 100,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: -5,
                            blurRadius: 15,
                            color: jetBlack,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 75,
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 21, right: 11),
                              child: Icon(
                                FeatherIcons.plus,
                                size: 18,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: SizeConfig.safeBlockHorizontal * 100 - 75,
                              child: Focus(
                                onFocusChange: (focus) {
                                  if (!focus) {
                                    setState(() {
                                      _addingTask = false;
                                    });
                                  }
                                },
                                child: Form(
                                  key: _formKey,
                                  child: TextFormField(
                                    focusNode: _focus,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Add task...",
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: jetBlack,
                                    ),
                                    autofocus: false,
                                    onFieldSubmitted: (value) async {
                                      if (value.isNotEmpty) {
                                        HapticFeedback.heavyImpact();
                                        setVolts();
                                        TaskItem newTask = TaskItem(
                                          name: value,
                                          completed: false,
                                          paused: false,
                                          order: _tasks.length -
                                              _completedTasks +
                                              1,
                                          date: getDateString(_date),
                                          secondsFocused: 0,
                                          secondsDistracted: 0,
                                          numPaused: 0,
                                          numDistracted: 0,
                                          voltsIncrement: 0,
                                          key: UniqueKey(),
                                        );
                                        newTask.onDismissed = (direction) {
                                          if (direction ==
                                              DismissDirection.startToEnd) {
                                            deferTask(newTask);
                                            AnalyticsProvider().logDeferTask(
                                                newTask, DateTime.now());
                                          } else {
                                            deleteTask(newTask);
                                            AnalyticsProvider().logDeleteTask(
                                                newTask, DateTime.now());
                                          }
                                        };
                                        newTask.onUpdate =
                                            (value) => newTask.name = value;
                                        setState(() {
                                          _tasks.insert(
                                              _tasks.length - _completedTasks,
                                              newTask);
                                        });
                                        _tasks[_tasks.length -
                                                    _completedTasks -
                                                    1]
                                                .id =
                                            await _firestoreProvider.addTask(
                                                newTask, getDateString(_date));
                                        _firestoreProvider.updateTasks(
                                            _tasks, getDateString(_date));
                                        _formKey.currentState.reset();
                                        AnalyticsProvider().logAddTask(
                                            newTask, DateTime.now());
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 25,
                  bottom: 80,
                  child: Offstage(
                    offstage: _keyboard,
                    child: AnimatedOpacity(
                      duration: keyboardDuration,
                      curve: keyboardCurve,
                      opacity: _keyboard ? 0 : 1,
                      child: SqrButton(
                        icon: Icon(
                          FeatherIcons.plus,
                          color: Colors.white,
                          size: 24,
                        ),
                        onTap: () {
                          setState(() {
                            _addingTask = true;
                          });
                          FocusScope.of(context).requestFocus(_focus);
                        },
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
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
