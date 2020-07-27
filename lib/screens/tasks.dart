import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:Focal/components/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/components/task_list.dart';
import 'package:Focal/utils/date.dart';

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
      child: Stack(children: <Widget>[
        Positioned(
          right: 0,
          top: 0,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              top: 30,
            ),
            child: Row(
              children: <Widget>[
                Text(
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
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: IconButton(
                      onPressed: () {
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
                      icon: FaIcon(FontAwesomeIcons.calendar)),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          top: 100,
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: TaskList(
                callback: () => setState(() => _loading = false), key: _key),
          ),
        ),
      ]),
    );
  }
}
