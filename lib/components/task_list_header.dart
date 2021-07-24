import 'package:flutter/material.dart';
import 'package:Focal/utils/date.dart';

class TaskListHeader extends StatelessWidget {
  final dynamic title;

  const TaskListHeader({
    this.title,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Text(
        this.title is String
            ? this.title
            : this.title == DateProvider().today
                ? 'Today, ${DateProvider().weekdayString(this.title, false)} ${DateProvider().monthString(this.title, false)} ${this.title.day}'
                : this.title == DateProvider().tomorrow
                    ? 'Tomorrow, ${DateProvider().weekdayString(this.title, false)} ${DateProvider().monthString(this.title, false)} ${this.title.day}'
                    : '${DateProvider().weekdayString(this.title, false)} ${DateProvider().monthString(this.title, false)} ${this.title.day}${this.title.year != DateProvider().today.year ? ' ' + this.title.year.toString() : ''}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
