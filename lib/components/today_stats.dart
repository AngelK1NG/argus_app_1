import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/task_stat_tile.dart';
import 'package:Focal/components/task_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/utils/date.dart';

class TodayStats extends StatefulWidget {
  final QuerySnapshot tasksSnapshot;
  final DocumentSnapshot dateSnapshot;
  TodayStats(
      {@required this.tasksSnapshot, @required this.dateSnapshot, Key key})
      : super(key: key);

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
    widget.tasksSnapshot.documents.forEach((task) {
      String name = task.data['name'];
      TaskItem newTask = TaskItem(
        name: name,
        id: task.documentID,
        completed: task.data['completed'],
        saved: task.data['saved'] == null ? false : task.data['saved'],
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
  }

  Widget taskColumn() {
    List<Widget> taskTiles = [];
    int maxTime = 0;
    int completedTasks = 0;
    int savedTasks = 0;
    _tasks.forEach((task) {
      if (task.completed) {
        if ((task.secondsFocused +
                task.secondsDistracted +
                task.secondsPaused) >
            maxTime) {
          maxTime =
              task.secondsFocused + task.secondsDistracted + task.secondsPaused;
        }
        completedTasks++;
      } else if (task.saved) {
        if ((task.secondsFocused +
                task.secondsDistracted +
                task.secondsPaused) >
            maxTime) {
          maxTime =
              task.secondsFocused + task.secondsDistracted + task.secondsPaused;
        }
        savedTasks++;
      }
    });
    if (completedTasks > 0) {
      taskTiles.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Text(
            'Completed tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          )));
      _tasks.forEach((task) {
        if (task.completed) {
          taskTiles.add(Padding(
            padding: const EdgeInsets.only(
              bottom: 20,
            ),
            child: TaskStatTile(maxTime: maxTime, task: task, completed: true),
          ));
        }
      });
    }
    if (savedTasks > 0) {
      taskTiles.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Text(
            'Saved tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor,
            ),
          )));
      _tasks.forEach((task) {
        if (!task.completed && task.saved) {
          taskTiles.add(Padding(
            padding: const EdgeInsets.only(
              bottom: 20,
            ),
            child: TaskStatTile(maxTime: maxTime, task: task, completed: false),
          ));
        }
      });
    }
    return Column(children: taskTiles);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.dateSnapshot.data['completedTasks'] == null) {
        _completedTasks = 0;
      } else {
        _completedTasks = widget.dateSnapshot.data['completedTasks'];
      }
      if (widget.dateSnapshot.data['totalTasks'] == null) {
        _totalTasks = 0;
      } else {
        _totalTasks = widget.dateSnapshot.data['totalTasks'];
      }
      if (widget.dateSnapshot.data['secondsFocused'] == null) {
        _timeFocused = Duration(seconds: 0);
      } else {
        _timeFocused =
            Duration(seconds: widget.dateSnapshot.data['secondsFocused']);
      }
      if (widget.dateSnapshot.data['secondsDistracted'] == null) {
        _timeDistracted = Duration(seconds: 0);
      } else {
        _timeDistracted =
            Duration(seconds: widget.dateSnapshot.data['secondsDistracted']);
      }
      if (widget.dateSnapshot.data['numDistracted'] == null) {
        _numDistracted = 0;
      } else {
        _numDistracted = widget.dateSnapshot.data['numDistracted'];
      }
      if (widget.dateSnapshot.data['numPaused'] == null) {
        _numPaused = 0;
      } else {
        _numPaused = widget.dateSnapshot.data['numPaused'];
      }
    });
    getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 1, right: 1),
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
                      backgroundColor: jetBlack,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
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
                                  .toString() +
                              '%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          )),
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
                          (_timeFocused.inMinutes % 60)
                              .toString()
                              .padLeft(2, "0") +
                          ":" +
                          (_timeFocused.inSeconds % 60)
                              .toString()
                              .padLeft(2, "0"),
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
                            (_timeDistracted.inMinutes % 60)
                                .toString()
                                .padLeft(2, "0") +
                            ":" +
                            (_timeDistracted.inSeconds % 60)
                                .toString()
                                .padLeft(2, "0"),
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
                  ]),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 50,
            bottom: 25,
          ),
          child: taskColumn(),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 50,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  text: (_numDistracted == 1
                      ? 'Distraction: '
                      : 'Distractions: '),
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
    );
  }
}
