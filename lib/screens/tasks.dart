import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../components/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/components/task_list.dart';

class TasksPage extends StatefulWidget {
  TasksPage({Key key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _date;
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    setState(() {
      var now = DateTime.now();
      String day = now.day.toString();
      String month = now.month.toString();
      String year = now.year.toString();
      if (day.length == 1) {
        day = '0' + day;
      }
      if (month.length == 1) {
        month = '0' + month;
      }
      _date = month + day + year;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context).user;
    return WrapperWidget(
      nav: true,
      child: Stack(children: <Widget>[
        Positioned(
          right: 0,
          top: 0,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 38,
              top: 30,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  "Today",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  width: 35,
                  child: IconButton(
                      onPressed: () {},
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
            child: TaskList(date: _date, userId: user.uid),
          ),
        ),
      ]),
    );
  }
}
