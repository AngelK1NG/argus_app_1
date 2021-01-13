import 'package:flutter/material.dart';

class TaskListHeader extends StatelessWidget {
  final String date;

  const TaskListHeader({
    @required this.date,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      alignment: Alignment.centerLeft,
      height: 20,
      child: Text(
        date != 'Completed'
            ? '${DateTime.parse(this.date).month.toString()}/${DateTime.parse(this.date).day}'
            : 'Completed',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
