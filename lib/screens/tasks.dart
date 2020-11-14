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

class TasksPage extends StatefulWidget {
  final Function goToPage;

  TasksPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  SharedPreferences _prefs;
  FocusNode _focus = new FocusNode();
  final _formKey = GlobalKey<FormState>();
  String _date = getDateString(DateTime.now());
  FirebaseUser user;
  bool _loading = true;
  bool _dateLoading = true;
  bool _addingTask = false;
  bool _editingTask = false;
  bool _keyboard = false;
  List<TaskItem> _tasks = [];
  List<TaskItem> _tmrTasks = [];
  int _completedTasks = 0;
  String _dateString = 'Today';
  String _secondaryDateString;

  void getCompletedTasks() {
    FirebaseUser user = context.read<User>().user;
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('dates')
        .document(_date);
    dateDoc.get().then((snapshot) {
      if (snapshot.data == null) {
        _completedTasks = 0;
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
        .collection('dates')
        .document(_date)
        .collection('tasks')
        .orderBy('order')
        .getDocuments()
        .then((snapshot) {
      if (mounted) {
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
          });
        });
        setState(() {
          _loading = false;
        });
      }
    });
  }

  void deferTask(TaskItem task) {
    final date = _date;
    final tasks = _tasks;
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    setState(() {
      _tasks.remove(_tasks.firstWhere((tasku) => tasku.id == task.id));
      if (task.completed) {
        _completedTasks--;
      }
    });
    updateTaskOrder();
    firestoreProvider.deleteTask(task, _date);
    firestoreProvider.updateTasks(_tasks, _date);
    String tomorrow =
        getDateString(DateTime.parse(_date).add(Duration(days: 1)));
    _tmrTasks = [];
    int completedTasks = 0;
    FirebaseUser user = context.read<User>().user;
    db
        .collection('users')
        .document(user.uid)
        .collection('dates')
        .document(tomorrow)
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
          key: UniqueKey(),
          date: tomorrow,
        );
        _tmrTasks.add(newTask);
        if (newTask.completed) {
          completedTasks++;
        }
      });
      _tmrTasks.insert(_tmrTasks.length - completedTasks, task);
      _tmrTasks[_tmrTasks.length - completedTasks - 1].id =
          await firestoreProvider.addTask(task, tomorrow);
      firestoreProvider.updateTasks(_tmrTasks, tomorrow);
      Scaffold.of(context).showSnackBar(SnackBar(
        padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
        content: Text(task.name + ' has been deferred to tomorrow'),
        duration: snackbarDuration,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            _tmrTasks
                .remove(_tmrTasks.firstWhere((tasku) => tasku.id == task.id));
            firestoreProvider.deleteTask(task, tomorrow);
            firestoreProvider.updateTasks(_tmrTasks, tomorrow);
            if (mounted) {
              if (date == _date) {
                setState(() {
                  _tasks.insert(task.order - 1, task);
                  if (task.completed) {
                    _completedTasks++;
                  }
                });
                updateTaskOrder();
                await firestoreProvider.addTask(task, _date);
                firestoreProvider.updateTasks(_tasks, _date);
              } else {
                tasks.insert(task.order - 1, task);
                await firestoreProvider.addTask(task, date);
                firestoreProvider.updateTasks(tasks, date);
                getTasks();
              }
            } else {
              tasks.insert(task.order - 1, task);
              await firestoreProvider.addTask(task, date);
              firestoreProvider.updateTasks(tasks, date);
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
    setState(() {
      _tasks.remove(_tasks.firstWhere((tasku) => tasku.id == task.id));
      if (task.completed) {
        _completedTasks--;
      }
    });
    updateTaskOrder();
    firestoreProvider.deleteTask(task, _date);
    firestoreProvider.updateTasks(_tasks, _date);
    Scaffold.of(context).showSnackBar(SnackBar(
      padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
      content: Text(task.name + ' has been deleted'),
      duration: snackbarDuration,
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          if (mounted) {
            if (date == _date) {
              setState(() {
                _tasks.insert(task.order - 1, task);
                if (task.completed) {
                  _completedTasks++;
                }
              });
              updateTaskOrder();
              await firestoreProvider.addTask(task, _date);
              firestoreProvider.updateTasks(_tasks, _date);
            } else {
              tasks.insert(task.order - 1, task);
              await firestoreProvider.addTask(task, date);
              firestoreProvider.updateTasks(tasks, date);
              getTasks();
            }
          } else {
            tasks.insert(task.order - 1, task);
            await firestoreProvider.addTask(task, date);
            firestoreProvider.updateTasks(tasks, date);
          }
        },
      ),
    ));
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
      if ((date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day) ||
          (date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day - 1) ||
          (date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day + 1)) {
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
    getCompletedTasks();
    getTasks();
  }

  void setToday() async {
    _prefs = await SharedPreferences.getInstance();
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

    FirebaseUser user = Provider.of<User>(context, listen: false).user;
    FirestoreProvider firestoreProvider = FirestoreProvider(user);
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
                            setDate(
                                DateTime.parse(_date).add(Duration(days: -1)));
                            FocusScope.of(context).unfocus();
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
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
                            FocusScope.of(context).unfocus();
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
                            setDate(
                                DateTime.parse(_date).add(Duration(days: 1)));
                            FocusScope.of(context).unfocus();
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
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
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: loadingDuration,
          curve: loadingCurve,
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
                      ? MediaQuery.of(context).viewInsets.bottom
                      : -150,
                  left: 0,
                  right: 0,
                  child: Offstage(
                    offstage: !_addingTask,
                    child: AnimatedContainer(
                      duration: loadingDuration,
                      curve: loadingCurve,
                      height: 75,
                      width: SizeConfig.safeBlockHorizontal * 100,
                      alignment: Alignment.centerLeft,
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
                                      TaskItem newTask = TaskItem(
                                        name: value,
                                        completed: false,
                                        paused: false,
                                        key: UniqueKey(),
                                        order:
                                            _tasks.length - _completedTasks + 1,
                                        date: _date,
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
                                          await firestoreProvider.addTask(
                                              newTask, _date);
                                      firestoreProvider.updateTasks(
                                          _tasks, _date);
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
