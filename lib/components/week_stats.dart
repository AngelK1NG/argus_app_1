import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/weekly_chart.dart';
import 'package:Focal/components/chart_value.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/date.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class WeekStats extends StatefulWidget {
  final VoidCallback callback;
  WeekStats({@required this.callback, Key key}) : super(key: key);

  @override
  _WeekStatsState createState() => _WeekStatsState();
}

class _WeekStatsState extends State<WeekStats> {
  List<String> days = [];
  List<ChartValue> totalDistracted = [];
  List<ChartValue> totalPaused = [];

  void getThisWeeksDays() {
    var now = DateTime.now();
    now = now.subtract(new Duration(days: now.weekday));
    days.add(getDateString(now));
    now = now.add(new Duration(days: 1));
    while (now.weekday != 7) {
      days.add(getDateString(now));
      now = now.add(new Duration(days: 1));
    }
    print(days);
  }

  void getNumberOfEvents(String event) {
    FirebaseUser _user = Provider.of<User>(context, listen: false).user;
    for (int i = 0; i < days.length; i++) {
      DocumentReference dateDoc = db
          .collection('users')
          .document(_user.uid)
          .collection('tasks')
          .document(days[i]);
      dateDoc.get().then((snapshot) {
        if (snapshot.data == null || snapshot.data['num$event'] == null) {
          if (event == 'Distracted') {
            totalDistracted.add(ChartValue(date: days[i], val: 0));
          } else {
            totalPaused.add(ChartValue(date: days[i], val: 0));
          }
        } else {
          if (event == 'Distracted') {
            totalDistracted.add(
                ChartValue(date: days[i], val: snapshot.data['num$event']));
          } else {
            totalPaused.add(
                ChartValue(date: days[i], val: snapshot.data['num$event']));
          }
        }
        if (event == 'Distracted') {
          totalDistracted.sort((a, b) => a.date.compareTo(b.date));
        } else {
          totalPaused.sort((a, b) => a.date.compareTo(b.date));
        }
      });
      if (i == days.length - 1 && event == 'Paused') {
        Future.delayed(navDuration, () {
          widget.callback();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getThisWeeksDays();
    getNumberOfEvents('Distracted');
    getNumberOfEvents('Paused');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              '# of Distractions by Day',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            width: 300,
            height: 200,
            child: WeeklyChart(
              id: 'totalDistracted',
              data: totalDistracted,
              barColor: charts.ColorUtil.fromDartColor(Colors.red),
              key: UniqueKey(),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 25, bottom: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              '# of Pauses by Day',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            width: 300,
            height: 200,
            child: WeeklyChart(
              id: 'totalPaused',
              data: totalPaused,
              barColor: charts.ColorUtil.fromDartColor(Theme.of(context).hintColor),
              key: UniqueKey(),
            ),
          ),
        ],
      ),
    );
  }
}