import 'package:flutter/material.dart';
import '../components/wrapper.dart';
import '../constants.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/date.dart';
import 'package:flutter/services.dart';
import 'package:Focal/components/task_stat_bar.dart';
import 'package:Focal/components/task_item.dart';

class StatisticsPage extends StatefulWidget {
  StatisticsPage({Key key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Duration _timeSpent = new Duration();
  int _completedTasks;
  int _totalTasks;
  bool _loading = true;
  String _timeFrame = 'today';
  List<TaskItem> _tasks = [];
  String _date = getDateString(DateTime.now());

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
          order: task.data['order'],
          focused: task.data['focused'],
          distracted: task.data['distracted'],
          paused: task.data['paused'],
          key: UniqueKey(),
          date: _date,
        );
        setState(() {
          _tasks.add(newTask);
          _loading = false;
        });
      });
    });
  }

  Widget taskColumn() {
    List<Widget> taskBars = [];
    int maxTime = 0;
    _tasks.forEach((task) {
      if ((task.focused + task.distracted + task.paused) > maxTime &&
          task.completed) {
        maxTime = task.focused + task.distracted + task.paused;
      }
    });
    _tasks.forEach((task) {
      if (task.completed) {
        taskBars.add(Padding(
          padding: const EdgeInsets.only(
            bottom: 20,
          ),
          child: TaskStatBar(maxTime: maxTime, task: task),
        ));
      }
    });
    return Column(children: taskBars);
  }

  @override
  void initState() {
    super.initState();
    FirebaseUser user = Provider.of<User>(context, listen: false).user;
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date);
    dateDoc.get().then((snapshot) {
      setState(() {
        if (snapshot.data['completedTasks'] == null) {
          _completedTasks = 0;
        } else {
          _completedTasks = snapshot.data['completedTasks'];
        }
        if (snapshot.data['totalTasks'] == null) {
          _totalTasks = 0;
        } else {
          _totalTasks = snapshot.data['totalTasks'];
        }
        if (snapshot.data['secondsSpent'] == null) {
          _timeSpent = Duration(seconds: 0);
        } else {
          _timeSpent = Duration(seconds: snapshot.data['secondsSpent']);
        }
      });
      getTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WrapperWidget(
      loading: _loading,
      nav: true,
      cardPosition: MediaQuery.of(context).size.height / 2 - 240,
      backgroundColor: Theme.of(context).primaryColor,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: 30,
            top: 30,
            child: Text(
              'Statistics',
              style: headerTextStyle,
            ),
          ),
          Positioned(
              right: 0,
              left: 0,
              top: MediaQuery.of(context).size.height / 2 - 240,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      setState(() {
                        _timeFrame = 'today';
                      });
                    },
                    child: Container(
                      height: 30,
                      width: 150,
                      decoration: BoxDecoration(
                          color: _timeFrame == 'today'
                              ? Theme.of(context).accentColor
                              : Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15))),
                      child: Center(
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 12,
                            color: _timeFrame == 'today'
                                ? Colors.white
                                : Theme.of(context).accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      setState(() {
                        _timeFrame = 'week';
                      });
                    },
                    child: Container(
                      height: 30,
                      width: 150,
                      decoration: BoxDecoration(
                          color: _timeFrame == 'week'
                              ? Theme.of(context).accentColor
                              : Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15))),
                      child: Center(
                        child: Text(
                          'Week',
                          style: TextStyle(
                            fontSize: 12,
                            color: _timeFrame == 'week'
                                ? Colors.white
                                : Theme.of(context).accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          Positioned(
              right: 30,
              left: 30,
              top: MediaQuery.of(context).size.height / 2 - 180,
              child: taskColumn()),
        ],
      ),
    );
  }
}
