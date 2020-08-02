import 'package:flutter/material.dart';
import 'task_item.dart';
import 'package:Focal/constants.dart';

class TaskStatTile extends StatelessWidget {
  final int maxTime;
  final TaskItem task;
  final bool completed;
  const TaskStatTile({@required this.maxTime, @required this.task, @required this.completed});

  @override
  Widget build(BuildContext context) {
    double height = 10;
    double maxLength = 250;

    return SizedBox(
      height: 38,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              task.name,
              style: TextStyle(
                fontSize: 16,
                color: completed ? jetBlack : Theme.of(context).accentColor,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              (task.secondsFocused ~/ 60)
                      .toString()
                      .padLeft(2, "0") +
                  ":" +
                  (task.secondsFocused % 60)
                      .toString()
                      .padLeft(2, "0"),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Stack(
              children: <Widget>[
                Container(
                  height: height,
                  width: maxTime == 0 ? 0 : (task.secondsPaused + task.secondsDistracted + task.secondsFocused) / maxTime * maxLength,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Container(
                  height: height,
                  width: maxTime == 0 ? 0 : (task.secondsDistracted + task.secondsFocused) / maxTime * maxLength,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.red,
                  ),
                ),
                Container(
                  height: height,
                  width: maxTime == 0 ? 0 : task.secondsFocused / maxTime * maxLength,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
