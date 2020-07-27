import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Focal/components/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/components/task_list.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/sqr_button.dart';

class TasksPage extends StatefulWidget {
  TasksPage({Key key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final GlobalKey<TaskListState> _key = GlobalKey();
  String _date;
  FirebaseUser user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      _date = getDateString(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context, listen: false).user;
    return WrapperWidget(
      loading: _loading,
      nav: true,
      cardPosition: MediaQuery.of(context).size.height / 2 - 240,
      backgroundColor: Theme.of(context).primaryColor,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: 30,
            top: 30,
            child: Text(
              (DateTime.parse(_date).year == DateTime.now().year &&
                      DateTime.parse(_date).month == DateTime.now().month &&
                      DateTime.parse(_date).day == DateTime.now().day)
                  ? "Today"
                  : (DateTime.parse(_date).year == DateTime.now().year &&
                          DateTime.parse(_date).month ==
                              DateTime.now().month &&
                          DateTime.parse(_date).day ==
                              DateTime.now().day + 1)
                      ? "Tomorrow"
                      : DateTime.parse(_date).month.toString() +
                          "/" +
                          DateTime.parse(_date).day.toString(),
              style: headerTextStyle,
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            top: MediaQuery.of(context).size.height / 2 - 240,
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2 + 240,
              child: TaskList(
                  callback: () => setState(() => _loading = false), key: _key),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 30,
            child: SqrButton(
              icon: Icon(Icons.calendar_today, color: Colors.white, size: 28,),
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(_date),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2120),
                ).then((date) {
                  if (date != null) {
                    setState(() {
                      _date = getDateString(date);
                      _key.currentState.setDate(_date);
                    });
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
