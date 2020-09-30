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
import 'package:percent_indicator/percent_indicator.dart';

class TasksPage extends StatefulWidget {
  final Function goToPage;

  TasksPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  FocusNode _focus = new FocusNode();
  final _formKey = GlobalKey<FormState>();
  String _date;
  FirebaseUser user;
  bool _loading = true;
  bool _addingTask = false;
  bool _editingTask = false;
  bool _keyboard = false;
  List<TaskItem> _tasks = [];
  int _completedTasks;
  String _dateString = 'Today';
  String _secondaryDateString;

  void getCompletedTasks() {
    FirebaseUser user = context.read<User>().user;
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date);
    dateDoc.get().then((snapshot) {
      if (snapshot.data == null) {
        _completedTasks = 0;
        dateDoc.setData({
          'completedTasks': 0,
          'totalTasks': 0,
        });
      } else {
        setState(() {
          _completedTasks = snapshot.data['completedTasks'];
        });
      }
    });
  }

  void getTasks() {
    _tasks = [];
    FirebaseUser user = context.read<User>().user;
    db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date)
        .collection('tasks')
        .orderBy('order')
        .getDocuments()
        .then((snapshot) {
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
          key: UniqueKey(),
          date: _date,
        );
        newTask.onDismissed = () {
          removeTask(newTask);
          AnalyticsProvider().logDeleteTask(newTask, DateTime.now());
        };
        newTask.onUpdate = (value) => newTask.name = value;
        setState(() {
          _tasks.add(newTask);
        });
      });
      Future.delayed(cardSlideDuration, () {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      });
    });
  }

  void removeTask(TaskItem task) {
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    setState(() {
      _tasks.remove(_tasks.firstWhere((tasku) => tasku.id == task.id));
      if (task.completed) {
        _completedTasks--;
      }
    });
    firestoreProvider.deleteTask(task, _date);
    firestoreProvider.updateTasks(_tasks, _date);
  }

  void setDate(DateTime date) {
    setState(() {
      _loading = true;
      _date = getDateString(date);
      if (date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day) {
        _dateString = 'Today';
      } else if (date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day - 1) {
        _dateString = 'Yesterday';
      } else if (date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day + 1) {
        _dateString = 'Tomorrow';
      } else {
        switch (date.weekday) {
          case 1: {
            _dateString = 'Monday';
            break;
          }
          case 2: {
            _dateString = 'Tuesday';
            break;
          }
          case 3: {
            _dateString = 'Wednesday';
            break;
          }
          case 4: {
            _dateString = 'Thursday';
            break;
          }
          case 5: {
            _dateString = 'Friday';
            break;
          }
          case 6: {
            _dateString = 'Saturday';
            break;
          }
          case 7: {
            _dateString = 'Sunday';
            break;
          }
        }
      }
      if ((date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day) ||
          (date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day - 1) ||
          (date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day + 1)) {
        switch (date.weekday) {
          case 1: {
            _secondaryDateString = 'Mon ' + date.month.toString() + '/' + date.day.toString();
            break;
          }
          case 2: {
            _secondaryDateString = 'Tue ' + date.month.toString() + '/' + date.day.toString();
            break;
          }
          case 3: {
            _secondaryDateString = 'Wed ' + date.month.toString() + '/' + date.day.toString();
            break;
          }
          case 4: {
            _secondaryDateString = 'Thu ' + date.month.toString() + '/' + date.day.toString();
            break;
          }
          case 5: {
            _secondaryDateString = 'Fri ' + date.month.toString() + '/' + date.day.toString();
            break;
          }
          case 6: {
            _secondaryDateString = 'Sat ' + date.month.toString() + '/' + date.day.toString();
            break;
          }
          case 7: {
            _secondaryDateString = 'Sun ' + date.month.toString() + '/' + date.day.toString();
            break;
          }
        }
      } else {
        _secondaryDateString = date.month.toString() + '/' + date.day.toString();
      }
    });
    getCompletedTasks();
    getTasks();
  }

  @override
  void initState() {
    super.initState();
    setDate(DateTime.now());
    KeyboardVisibility.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          _keyboard = visible;
        });
        if (!visible) {
          FocusScope.of(context).unfocus();
          setState(() {
            _addingTask = false;
            _editingTask = false;
          });
        } else {
          if (!_addingTask) {
            setState(() {
              _editingTask = true;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle dateTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
    final TextStyle todayTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).primaryColor,
    );

    FirebaseUser user = Provider.of<User>(context, listen: false).user;
    FirestoreProvider firestoreProvider = FirestoreProvider(user);
    return WillPopScope(
      onWillPop: () async => widget.goToPage(0),
      child: Stack(children: <Widget>[
        Positioned(
          left: 0,
          right: 0,
          top: SizeConfig.safeBlockVertical * 5 - 20,
          child: Center(
            child: Text(
              _secondaryDateString,
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
          top: SizeConfig.safeBlockVertical * 5 - 20,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx > 50) {
                setDate(DateTime.parse(_date).add(Duration(days: -1)));
                FocusScope.of(context).unfocus();
              }
              if (details.velocity.pixelsPerSecond.dx < -50) {
                setDate(DateTime.parse(_date).add(Duration(days: 1)));
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
                      setDate(DateTime.parse(_date).add(Duration(days: -1)));
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (DateTime.parse(_date).year ==
                                    DateTime.now().year &&
                                DateTime.parse(_date).month ==
                                    DateTime.now().month &&
                                DateTime.parse(_date).day - 1 ==
                                    DateTime.now().day)
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Center(
                        child: Text(
                            DateTime.parse(_date)
                                .add(Duration(days: -1))
                                .day
                                .toString(),
                            style: (DateTime.parse(_date).year ==
                                        DateTime.now().year &&
                                    DateTime.parse(_date).month ==
                                        DateTime.now().month &&
                                    DateTime.parse(_date).day - 1 ==
                                        DateTime.now().day)
                                ? todayTextStyle
                                : dateTextStyle),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(_date),
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
                      setDate(DateTime.parse(_date).add(Duration(days: 1)));
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (DateTime.parse(_date).year ==
                                    DateTime.now().year &&
                                DateTime.parse(_date).month ==
                                    DateTime.now().month &&
                                DateTime.parse(_date).day + 1 ==
                                    DateTime.now().day)
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Center(
                        child: Text(
                            DateTime.parse(_date)
                                .add(Duration(days: 1))
                                .day
                                .toString(),
                            style: (DateTime.parse(_date).year ==
                                        DateTime.now().year &&
                                    DateTime.parse(_date).month ==
                                        DateTime.now().month &&
                                    DateTime.parse(_date).day + 1 ==
                                        DateTime.now().day)
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
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: loadingDuration,
          curve: loadingCurve,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 28,
                left: 28,
                top: SizeConfig.safeBlockVertical * 15 + 15,
                child: Center(
                  child: LinearPercentIndicator(
                    percent: (_tasks.length == null || _tasks.length == 0)
                        ? 0
                        : (_completedTasks / _tasks.length),
                    lineHeight: 25,
                    progressColor: Theme.of(context).accentColor,
                    backgroundColor: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                left: 0,
                top: SizeConfig.safeBlockVertical * 15 + 55,
                child: SizedBox(
                  height: _editingTask
                      ? SizeConfig.safeBlockVertical * 85 -
                          MediaQuery.of(context).viewInsets.bottom -
                          55
                      : SizeConfig.safeBlockVertical * 85 - 135,
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
                          firestoreProvider.updateTasks(tasks, _date);
                        } else {
                          tasks.insert(newIndex, task);
                          firestoreProvider.updateTasks(tasks, _date);
                        }
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
                    ? MediaQuery.of(context).viewInsets.bottom
                    : -150,
                left: 0,
                right: 0,
                child: Offstage(
                  offstage: !_addingTask,
                  child: Container(
                    height: 75,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      color: Color(0xff666666),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: -5,
                          blurRadius: 15,
                        )
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 21, right: 11),
                          child: Icon(
                            FeatherIcons.plus,
                            size: 18,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width - 75,
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
                                  color: Colors.white,
                                ),
                                autofocus: false,
                                onFieldSubmitted: (value) async {
                                  if (value.isNotEmpty) {
                                    HapticFeedback.heavyImpact();
                                    TaskItem newTask = TaskItem(
                                      id: '',
                                      name: value,
                                      completed: false,
                                      paused: false,
                                      key: UniqueKey(),
                                      order: _tasks.length - _completedTasks,
                                      date: _date,
                                    );
                                    newTask.onDismissed = () {
                                      removeTask(newTask);
                                      AnalyticsProvider().logDeleteTask(
                                          newTask, DateTime.now());
                                    };
                                    newTask.onUpdate =
                                        (value) => newTask.name = value;
                                    setState(() {
                                      _tasks.insert(
                                          _tasks.length - _completedTasks,
                                          newTask);
                                    });
                                    String userId = user.uid;
                                    db
                                        .collection('users')
                                        .document(userId)
                                        .collection('tasks')
                                        .document(_date)
                                        .collection('tasks')
                                        .add({
                                      'name': newTask.name,
                                      'order': newTask.order,
                                      'completed': newTask.completed,
                                      'paused': newTask.paused,
                                    }).then((doc) {
                                      _tasks[_tasks.length -
                                              _completedTasks -
                                              1]
                                          .id = doc.documentID;
                                      firestoreProvider.updateTasks(
                                          _tasks, _date);
                                    });
                                    _formKey.currentState.reset();
                                    AnalyticsProvider()
                                        .logAddTask(newTask, DateTime.now());
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
