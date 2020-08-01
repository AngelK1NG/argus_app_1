import 'package:Focal/components/chart_value.dart';
import 'package:Focal/components/task_item.dart';
import 'package:Focal/components/weekly_chart.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Focal/components/wrapper.dart';
import 'package:Focal/constants.dart';
import 'package:flutter/services.dart';
import 'package:Focal/components/today_stats.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StatisticsPage extends StatefulWidget {
  StatisticsPage({Key key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _loading = true;
  String _timeFrame = 'today';
  List<String> days = [];
  List<chartValue> totalDistracted = [];
  List<chartValue> totalPaused = [];
  List<chartValue> totalDistractedEx = [
    chartValue(date: 'S', val: 3),
    chartValue(date: 'M', val: 4),
    chartValue(date: 'Tu', val: 7),
    chartValue(date: 'W', val: 13),
    chartValue(date: 'Th', val: 2),
    chartValue(date: 'F', val: 1),
    chartValue(date: 'Su', val: 10),
  ];
  List<TaskItem> tasks = [
    TaskItem(date: 'M', name: 's', numDistracted: 10, completed: true),
    TaskItem(date: 'Tu', name: 's', numDistracted: 3, completed: true),
    TaskItem(date: 'W', name: 's', numDistracted: 6, completed: true),
    TaskItem(date: 'Th', name: 's', numDistracted: 8, completed: true),
    TaskItem(date: 'F', name: 's', numDistracted: 12, completed: true),
    TaskItem(date: 'Sa', name: 's', numDistracted: 16, completed: true),
    TaskItem(date: 'Su', name: 's', numDistracted: 5, completed: true),
  ];

  void getThisWeeksDays() {
    var now = DateTime.now();
    days.add(getDateString(now));
    while (now.weekday != 1) {
      now = now.subtract(new Duration(days: 1));
      days.add(getDateString(now));
    }
    now = now.subtract(new Duration(days: 1));
    days.add(getDateString(now));
    days = days.reversed.toList();
    print(days);
  }

  void getNumberOfEvents(String event) {
    FirebaseUser _user = Provider.of<User>(context, listen: false).user;
    for (int i = 0; i < days.length; i++) {
      print('$i : ${days[i]}');
      DocumentReference dateDoc = db
          .collection('users')
          .document(_user.uid)
          .collection('tasks')
          .document(days[i]);
      dateDoc.get().then((snapshot) {
        if (snapshot.data == null || snapshot.data['num$event'] == null) {
          if (event == 'Distracted') {
            totalDistracted.add(chartValue(date: days[i], val: 0));
          } else {
            totalPaused.add(chartValue(date: days[i], val: 0));
          }
        } else {
          if (event == 'Distracted') {
            totalDistracted.add(
                chartValue(date: days[i], val: snapshot.data['num$event']));
          } else {
            totalPaused.add(
                chartValue(date: days[i], val: snapshot.data['num$event']));
          }
        }
        if (event == 'Distracted') {
          totalDistracted.sort((a, b) => a.date.compareTo(b.date));
        } else {
          totalPaused.sort((a, b) => a.date.compareTo(b.date));
        }
        print('result');
        for (int i = 0; i < totalDistracted.length; i++) {
          print('$i ${totalDistracted[i].date} ${totalDistracted[i].val}');
        }
      });
    }
  }

  @override
  void initState() {
    getThisWeeksDays();
    getNumberOfEvents('Distracted');
    getNumberOfEvents('Paused');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WrapperWidget(
      loading: _loading,
      nav: true,
      cardPosition: MediaQuery.of(context).size.height / 2 - 240,
      backgroundColor: Theme.of(context).primaryColor,
      staticChild: Stack(children: <Widget>[
        Positioned(
          right: 40,
          top: 40,
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
                  if (_timeFrame != 'today') {
                    setState(() {
                      _loading = true;
                      _timeFrame = 'today';
                    });
                  }
                },
                child: Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width / 2 - 40,
                  decoration: BoxDecoration(
                      color: _timeFrame == 'today'
                          ? Theme.of(context).accentColor
                          : Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15))),
                  child: Center(
                    child: Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 12,
                        color: _timeFrame == 'today'
                            ? Colors.white
                            : Theme.of(context).accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  if (_timeFrame != 'week') {
                    setState(() {
                      _timeFrame = 'week';
                    });
                  }
                },
                child: Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width / 2 - 40,
                  decoration: BoxDecoration(
                      color: _timeFrame == 'week'
                          ? Theme.of(context).accentColor
                          : Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15))),
                  child: Center(
                    child: Text(
                      'Week',
                      style: TextStyle(
                        fontSize: 12,
                        color: _timeFrame == 'week'
                            ? Colors.white
                            : Theme.of(context).accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
      dynamicChild: Stack(
        children: <Widget>[
          Positioned(
            right: 40,
            left: 40,
            top: MediaQuery.of(context).size.height / 2 - 180,
            child: _timeFrame == 'today'
                ? TodayStats(callback: () => setState(() => _loading = false))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '# of Distractions by Day',
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        width: 300,
                        height: 200,
                        child: weeklyChart(
                          data: totalDistracted,
                          barColor: charts.MaterialPalette.red.shadeDefault,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        '# of Pauses by Day',
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        width: 300,
                        height: 200,
                        child: weeklyChart(
                          data: totalPaused,
                          barColor: charts.MaterialPalette.gray.shadeDefault,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
