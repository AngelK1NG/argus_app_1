import 'package:flutter/material.dart';
import '../components/wrapper.dart';
import '../constants.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/date.dart';
import 'package:flutter/services.dart';

class StatisticsPage extends StatefulWidget {
  StatisticsPage({Key key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Duration _timeSpent = new Duration();
  int _completedTasks;
  int _totalTasks;
  bool _loading = true;
  String _timeFrame = 'today';

  @override
  void initState() {
    String date = getDateString(DateTime.now());
    super.initState();
    FirebaseUser user = Provider.of<User>(context, listen: false).user;
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(date);
    dateDoc.get().then((snapshot) {
      setState(() {
        if (snapshot.data['completedTasks'] == null) {
          _completedTasks = 0;
        } else {
          _completedTasks = snapshot.data['completedTasks'];
        }
        if (snapshot.data['totalTasks'] == null) {
          _totalTasks = 0;
        } else {
          _totalTasks = snapshot.data['totalTasks'];
        }
        if (snapshot.data['secondsSpent'] == null) {
          _timeSpent = Duration(seconds: 0);
        } else {
          _timeSpent = Duration(seconds: snapshot.data['secondsSpent']);
        }
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
              'Statistics',
              style: headerTextStyle,
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            top: MediaQuery.of(context).size.height / 2 - 240,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _timeFrame = 'today';
                    });
                  },
                  child: Container(
                    height: 30,
                    width: 150,
                    decoration: BoxDecoration(
                      color: _timeFrame == 'today' ? Theme.of(context).accentColor : Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
                    ),
                    child: Center(
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: _timeFrame == 'today' ? Colors.white : Theme.of(context).accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _timeFrame = 'week';
                    });
                  },
                  child: Container(
                    height: 30,
                    width: 150,
                    decoration: BoxDecoration(
                      color: _timeFrame == 'week' ? Theme.of(context).accentColor : Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15))
                    ),
                    child: Center(
                      child: Text(
                        'Week',
                        style: TextStyle(
                          fontSize: 12,
                          color: _timeFrame == 'week' ? Colors.white : Theme.of(context).accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}
