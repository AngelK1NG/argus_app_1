import 'package:flutter/material.dart';
import 'task_item.dart';
import 'package:Focal/constants.dart';

class TaskStatTile extends StatelessWidget {
  final TaskItem task;
  const TaskStatTile(
      {@required this.task});

  @override
  Widget build(BuildContext context) {
    Duration _timeFocused = Duration(seconds: task.secondsFocused);

    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(height: 1, color: Theme.of(context).dividerColor)
        ),
        SizedBox(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width - 125,
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: task.completed ? jetBlack : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Text(
                '${_timeFocused.inHours}h ${_timeFocused.inMinutes % 60}m',
                style: TextStyle(
                  fontSize: 14,
                  color: jetBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
