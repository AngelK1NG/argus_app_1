import 'package:flutter/material.dart';
import 'task_item.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:intl/intl.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

class StatsTaskItem extends StatelessWidget {
  final TaskItem task;
  const StatsTaskItem({@required this.task});

  @override
  Widget build(BuildContext context) {
    Duration timeFocused = Duration(seconds: task.secondsFocused);
    NumberFormat voltsFormat = NumberFormat('###,##0.00');

    return Stack(
      children: [
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Theme.of(context).dividerColor)),
        SizedBox(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: SizeConfig.safeBlockHorizontal * 100 - 150,
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: task.completed
                        ? jetBlack
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        task.voltsIncrement >= 0
                            ? FeatherIcons.chevronUp
                            : FeatherIcons.chevronDown,
                        size: 14,
                        color: task.voltsIncrement >= 0
                            ? Theme.of(context).primaryColor
                            : Colors.red,
                      ),
                      Icon(
                        FeatherIcons.zap,
                        size: 14,
                        color: task.voltsIncrement >= 0
                            ? Theme.of(context).primaryColor
                            : Colors.red,
                      ),
                      Text(
                        voltsFormat.format(task.voltsIncrement.abs()),
                        style: TextStyle(
                          fontSize: 14,
                          color: task.voltsIncrement >= 0
                              ? Theme.of(context).primaryColor
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${timeFocused.inHours}h ${timeFocused.inMinutes % 60}m',
                    style: TextStyle(
                      fontSize: 14,
                      color: jetBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
