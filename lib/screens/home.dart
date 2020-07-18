import 'package:Focal/components/task_item.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../components/wrapper.dart';
import '../components/rct_button.dart';
import '../components/sqr_button.dart';
import '../constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer timer;
  DateTime _startTime;
  String _swatchDisplay = "00:00";
  double _taskPercent = 0.69;
  bool _doingTask = false;
  String _date;
  FirebaseUser _user;
  FirestoreProvider _firestoreProvider;
  List<TaskItem> _tasks = [];

  void startTask() {
    timer = new Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => setState(() {
              if (_doingTask) {
                final currentTime = DateTime.now();
                _swatchDisplay = currentTime
                        .difference(_startTime)
                        .inMinutes
                        .toString()
                        .padLeft(2, "0") +
                    ":" +
                    (currentTime.difference(_startTime).inSeconds % 60)
                        .toString()
                        .padLeft(2, "0");
              } else {
                timer.cancel();
              }
            }));
    setState(() {
      _doingTask = true;
      _startTime = DateTime.now();
    });
  }

  void stopTask() {
    setState(() {
      _doingTask = false;
      _swatchDisplay = "00:00";
    });
  }

  void abandonTask() {
    setState(() {
      _doingTask = false;
      _swatchDisplay = "00:00";
    });
    _firestoreProvider.deleteTask(_date, _tasks[0].id, _tasks[0].completed);
  }

  bool areTasksCompleted() {
    for (var task in _tasks) {
      print(task.completed);
      if (!task.completed) {
        return false;
      }
    }
    return true;
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
    _tasks.add(finishedTask);
    _tasks.remove(currentTask);
    firestoreProvider.addTask(finishedTask, _date);
    firestoreProvider.updateTaskOrder(_tasks, _date);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _date = getDateString(DateTime.now());
      _user = Provider.of<User>(context, listen: false).user;
      _firestoreProvider = FirestoreProvider(_user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: WrapperWidget(
        nav: !_doingTask,
        backgroundColor: _doingTask ? Colors.black : Colors.white,
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
            if (!snapshot.hasData ||
                snapshot.data.documents == null ||
                snapshot.data.documents.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.05),
                    child: Container(
                      width: 315,
                      padding: const EdgeInsets.only(bottom: 70),
                      child: Text(
                        _swatchDisplay,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w500,
                          color: _doingTask ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      width: 315,
                      child: Text('Add a task and start your day!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                          ))),
                  Padding(
                    padding: const EdgeInsets.only(top: 90),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RctButton(
                          onTap: () {
                            Navigator.pushNamed(context, '/tasks');
                          },
                          buttonWidth: 315,
                          buttonText: "Add task",
                          buttonColor: Colors.black,
                          textColor: Colors.white,
                          textSize: 32,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      width: 315,
                      height: 5,
                      child: Visibility(
                        visible: !_doingTask,
                        child: LinearProgressIndicator(
                          value: _taskPercent,
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Container(
                      alignment: Alignment.centerRight,
                      width: 315,
                      height: 24,
                      child: Visibility(
                        visible: !_doingTask,
                        child:
                            Text((_taskPercent * 100).toInt().toString() + "%",
                                style: TextStyle(
                                  fontSize: 24,
                                )),
                      ),
                    ),
                  ),
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.05),
                    child: Container(
                      width: 315,
                      padding: const EdgeInsets.only(bottom: 70),
                      child: areTasksCompleted()
                          ? Text(
                              'Done',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w500,
                                color: _doingTask ? Colors.white : Colors.black,
                              ),
                            )
                          : Text(
                              _swatchDisplay,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w500,
                                color: _doingTask ? Colors.white : Colors.black,
                              ),
                            ),
                    ),
                  ),
                  Container(
                    width: 315,
                    child: areTasksCompleted()
                        ? Text('Congrats! You are done for the day',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                            ))
                        : Text(
                            _tasks[0].name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              color: _doingTask ? Colors.white : Colors.black,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 90),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _doingTask
                            ? RctButton(
                                onTap: () {
                                  setState(() {
                                    _doingTask = false;
                                  });
                                  stopTask();
                                  completeTask(_user);
                                  _firestoreProvider
                                      .addCompletedTaskNumber(_date);
                                },
                                buttonWidth: 240,
                                buttonText: "Complete",
                                buttonColor: Colors.white,
                                textColor: Colors.black,
                                textSize: 32,
                              )
                            : areTasksCompleted()
                                ? RctButton(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/statistics');
                                    },
                                    buttonWidth: 315,
                                    buttonText: "Statistics",
                                    buttonColor: Colors.black,
                                    textColor: Colors.white,
                                    textSize: 32,
                                  )
                                : RctButton(
                                    onTap: () {
                                      setState(() {
                                        _doingTask = true;
                                      });
                                      startTask();
                                    },
                                    buttonWidth: 240,
                                    buttonText: "Start",
                                    buttonColor: Colors.black,
                                    textColor: Colors.white,
                                    textSize: 32,
                                  ),
                        areTasksCompleted()
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: SqrButton(
                                    onTap: () {
                                      Fluttertoast.showToast(
                                        msg:
                                            'Abandoned task: ${_tasks[0].name}',
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                      );
                                      abandonTask();
                                    },
                                    buttonColor: Theme.of(context).primaryColor,
                                    icon: FaIcon(
                                      FontAwesomeIcons.running,
                                      size: 32,
                                      color: Colors.white,
                                    )),
                              ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      width: 315,
                      height: 5,
                      child: Visibility(
                        visible: !_doingTask,
                        child: LinearProgressIndicator(
                          value: _taskPercent,
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Container(
                      alignment: Alignment.centerRight,
                      width: 315,
                      height: 24,
                      child: Visibility(
                        visible: !_doingTask,
                        child:
                            Text((_taskPercent * 100).toInt().toString() + "%",
                                style: TextStyle(
                                  fontSize: 24,
                                )),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
