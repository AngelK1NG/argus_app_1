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
  int _numDistracted;
  int _numPaused;
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
          secondsFocused: task.data['secondsFocused'],
          secondsDistracted: task.data['secondsDistracted'],
          secondsPaused: task.data['secondsPaused'],
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
        if ((task.secondsFocused + task.secondsDistracted + task.secondsPaused) > maxTime) {
          maxTime = task.secondsFocused + task.secondsDistracted + task.secondsPaused;
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
        if (snapshot.data['numDistracted'] == null) {
          _numDistracted = 0;
        } else {
          _numDistracted = snapshot.data['numDistracted'];
        }
        if (snapshot.data['numPaused'] == null) {
          _numPaused = 0;
        } else {
          _numPaused = snapshot.data['numPaused'];
        }
      });
      getTasks();
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2 + 180,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
              padding: EdgeInsets.only(top: 50, bottom: 25,),
              child: taskColumn(),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 50,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: (_numDistracted == 1 ? 'Distraction: ' : 'Distractions: '),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                      children: [
                        TextSpan(
                          text: _numDistracted.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: (_numPaused == 1 ? 'Pause: ' : 'Pauses: '),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).hintColor,
                      ),
                      children: [
                        TextSpan(
                          text: _numPaused.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}