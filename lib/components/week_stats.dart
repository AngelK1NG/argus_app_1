import 'package:flutter/material.dart';
import 'package:Focal/components/weekly_chart.dart';
import 'package:Focal/components/weekly_stacked_chart.dart';
import 'package:Focal/components/chart_value.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:Focal/utils/size_config.dart';

class WeekStats extends StatefulWidget {
  final List<Map> snapshots;
  WeekStats({@required this.snapshots, Key key}) : super(key: key);

  @override
  _WeekStatsState createState() => _WeekStatsState();
}

class _WeekStatsState extends State<WeekStats> {
  List<ChartValue> _numDistracted = [];
  List<ChartValue> _numPaused = [];
  List<ChartValue> _secondsPaused = [];
  List<ChartValue> _secondsDistracted = [];
  List<ChartValue> _secondsFocused = [];

  void getNumberOfEvents(String event, List<ChartValue> chartValues) {
    widget.snapshots.forEach((snapshot) {
      if (snapshot['data'] == null || snapshot['data'][event] == null) {
        chartValues.add(ChartValue(date: snapshot['documentID'], val: 0));
      } else {
        if (event.substring(0, 7) == 'seconds') {
          chartValues.add(ChartValue(
              date: snapshot['documentID'],
              val: snapshot['data'][event] ~/ 60));
        } else {
          chartValues.add(ChartValue(
              date: snapshot['documentID'], val: snapshot['data'][event]));
        }
      }
      chartValues.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  @override
  void initState() {
    super.initState();
    getNumberOfEvents('numDistracted', _numDistracted);
    getNumberOfEvents('numPaused', _numPaused);
    getNumberOfEvents('secondsPaused', _secondsPaused);
    getNumberOfEvents('secondsDistracted', _secondsDistracted);
    getNumberOfEvents('secondsFocused', _secondsFocused);
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
              'Total Minutes',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            width: SizeConfig.safeBlockHorizontal * 100 - 80,
            height: 200,
            child: WeeklyStackedChart(
              id: 'minutesData',
              data: [
                _secondsFocused,
                _secondsDistracted,
                _secondsPaused,
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
              'Number of Distractions',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            width: SizeConfig.safeBlockHorizontal * 100 - 80,
            height: 200,
            child: WeeklyChart(
              id: 'numDistracted',
              data: _numDistracted,
              barColor: charts.ColorUtil.fromDartColor(Colors.red),
              key: UniqueKey(),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 25, bottom: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              'Number of Pauses',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            width: SizeConfig.safeBlockHorizontal * 100 - 80,
            height: 200,
            child: WeeklyChart(
              id: 'numPaused',
              data: _numPaused,
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
