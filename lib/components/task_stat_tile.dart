import 'package:flutter/material.dart';
import 'task_item.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';

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
                width: SizeConfig.safeBlockHorizontal * 100 - 125,
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
                  color: Theme.of(context).primaryColor,
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
