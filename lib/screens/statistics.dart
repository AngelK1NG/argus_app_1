import 'package:flutter/material.dart';
import 'package:Focal/components/wrapper.dart';
import 'package:Focal/constants.dart';
import 'package:flutter/services.dart';
import 'package:Focal/components/today_stats.dart';
import 'package:Focal/components/week_stats.dart';

class StatisticsPage extends StatefulWidget {
  StatisticsPage({Key key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _loading = true;
  String _timeFrame = 'today';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WrapperWidget(
      loading: _loading,
      nav: true,
      cardPosition: 110,
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
          top: 130,
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
                      _loading = true;
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
            top: 200,
            child: SizedBox(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _timeFrame == 'today'
                  ? TodayStats(callback: () => setState(() => _loading = false))
                  : WeekStats(callback: () => setState(() => _loading = false)),
              ),
            )
          ),
        ],
      ),
    );
  }
}
