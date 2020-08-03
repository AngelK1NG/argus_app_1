import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/weekly_chart.dart';
import 'package:Focal/components/weekly_stacked_chart.dart';
import 'package:Focal/components/chart_value.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/date.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:Focal/utils/size_config.dart';

class WeekStats extends StatefulWidget {
  final VoidCallback callback;
  WeekStats({@required this.callback, Key key}) : super(key: key);

  @override
  _WeekStatsState createState() => _WeekStatsState();
}

class _WeekStatsState extends State<WeekStats> {
  List<String> days = [];
  List<ChartValue> numDistracted = [];
  List<ChartValue> numPaused = [];
  List<ChartValue> secondsPaused = [];
  List<ChartValue> secondsDistracted = [];
  List<ChartValue> secondsFocused = [];

  void getThisWeeksDays() {
    var now = DateTime.now();
    if (now.weekday != 7) {
      now = now.subtract(new Duration(days: now.weekday));
    }
    days.add(getDateString(now));
    now = now.add(new Duration(days: 1));
    while (now.weekday != 7) {
      days.add(getDateString(now));
      now = now.add(new Duration(days: 1));
    }
  }

  void getNumberOfEvents(String event, List<ChartValue> chartValues) {
    FirebaseUser _user = Provider.of<User>(context, listen: false).user;
    for (int i = 0; i < days.length; i++) {
      DocumentReference dateDoc = db
          .collection('users')
          .document(_user.uid)
          .collection('tasks')
          .document(days[i]);
      dateDoc.get().then((snapshot) {
        if (snapshot.data == null || snapshot.data[event] == null) {
          chartValues.add(ChartValue(date: days[i], val: 0));
        } else {
          if (event.substring(0, 7) == 'seconds') {
            chartValues.add(
                ChartValue(date: days[i], val: snapshot.data[event] ~/ 60));
          } else {
            chartValues
                .add(ChartValue(date: days[i], val: snapshot.data[event]));
          }
        }
        chartValues.sort((a, b) => a.date.compareTo(b.date));
      });
      if (i == days.length - 1 && event == 'secondsFocused') {
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
    getNumberOfEvents('numDistracted', numDistracted);
    getNumberOfEvents('numPaused', numPaused);
    getNumberOfEvents('secondsPaused', secondsPaused);
    getNumberOfEvents('secondsDistracted', secondsDistracted);
    getNumberOfEvents('secondsFocused', secondsFocused);
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
              'Minutes by Day',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            width: SizeConfig.safeBlockHorizontal * 90,
            height: SizeConfig.safeBlockHorizontal * 50,
            child: WeeklyStackedChart(
              id: 'minutesData',
              data: [
                secondsFocused,
                secondsDistracted,
                secondsPaused,
              ],
              colorList: [
                charts.ColorUtil.fromDartColor(Theme.of(context).primaryColor),
                charts.ColorUtil.fromDartColor(Colors.red),
                charts.ColorUtil.fromDartColor(Theme.of(context).hintColor),
              ],
              key: UniqueKey(),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 25, bottom: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              '# of Distractions by Day',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            width: SizeConfig.safeBlockHorizontal * 90,
            height: SizeConfig.safeBlockHorizontal * 50,
            child: WeeklyChart(
              id: 'numDistracted',
              data: numDistracted,
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
            width: SizeConfig.safeBlockHorizontal * 90,
            height: SizeConfig.safeBlockHorizontal * 50,
            child: WeeklyChart(
              id: 'numPaused',
              data: numPaused,
              barColor: charts.ColorUtil.fromDartColor(
                  Theme.of(context).dividerColor),
              key: UniqueKey(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 50),
          )
        ],
      ),
    );
  }
}
