import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/task_stat_tile.dart';
import 'package:Focal/components/task_item.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/date.dart';

class TodayStats extends StatefulWidget {
  final VoidCallback callback;
  TodayStats({@required this.callback, Key key}) : super(key: key);

  @override
  _TodayStatsState createState() => _TodayStatsState();
}

class _TodayStatsState extends State<TodayStats> {
  Duration _timeFocused = new Duration();
  Duration _timeDistracted = new Duration();
  int _completedTasks;
  int _totalTasks;
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
        });
      });
      widget.callback();
    });
  }

  Widget taskColumn() {
    List<Widget> taskTiles = [];
    int maxTime = 0;
    _tasks.forEach((task) {
      if (task.completed) {
        if ((task.focused + task.distracted + task.paused) > maxTime) {
          maxTime = task.focused + task.distracted + task.paused;
        }
      }
    });
    _tasks.forEach((task) {
      if (task.completed) {
        taskTiles.add(Padding(
          padding: const EdgeInsets.only(
            bottom: 20,
          ),
          child: TaskStatTile(maxTime: maxTime, task: task),
        ));
      }
    });
    return Column(children: taskTiles);
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
        if (snapshot.data['secondsFocused'] == null) {
          _timeFocused = Duration(seconds: 0);
        } else {
          _timeFocused = Duration(seconds: snapshot.data['secondsFocused']);
        }
        if (snapshot.data['secondsDistracted'] == null) {
          _timeDistracted = Duration(seconds: 0);
        } else {
          _timeDistracted = Duration(seconds: snapshot.data['secondsDistracted']);
        }
      });
      getTasks();
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: (_totalTasks == null || _totalTasks == 0)
                            ? 0
                            : (_completedTasks / _totalTasks),
                        backgroundColor: Colors.black,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          ((_totalTasks == null || _totalTasks == 0)
                                  ? 0
                                  : (_completedTasks / _totalTasks) * 100)
                              .toInt()
                              .toString() + '%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          )
                        ),
                        Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      _timeFocused.inHours.toString().padLeft(2, "0") +
                      ":" +
                      (_timeFocused.inMinutes % 60).toString().padLeft(2, "0") +
                      ":" +
                      (_timeFocused.inSeconds % 60).toString().padLeft(2, "0"),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Focused',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        _timeDistracted.inHours.toString().padLeft(2, "0") +
                        ":" +
                        (_timeDistracted.inMinutes % 60).toString().padLeft(2, "0") +
                        ":" +
                        (_timeDistracted.inSeconds % 60).toString().padLeft(2, "0"),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      'Distracted',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ]
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: taskColumn(),
          ),
        ],
      ),
    );
  }
}