import 'package:flutter/material.dart';
import 'task_item.dart';

class TaskStatBar extends StatelessWidget {
  final int maxTime;
  final TaskItem task;
  const TaskStatBar({@required this.maxTime, @required this.task});

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
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              ((task.focused + task.distracted) ~/ 60)
                      .toString()
                      .padLeft(2, "0") +
                  ":" +
                  ((task.focused + task.distracted) % 60)
                      .toString()
                      .padLeft(2, "0"),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
                  width: (task.paused + task.distracted + task.focused) /
                      maxTime *
                      maxLength,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Container(
                  height: height,
                  width: (task.distracted + task.focused) / maxTime * maxLength,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.red,
                  ),
                ),
                Container(
                  height: height,
                  width: task.focused / maxTime * maxLength,
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
