import 'package:flutter/material.dart';
import 'package:Focal/components/wrapper.dart';
import 'package:Focal/constants.dart';
import 'package:flutter/services.dart';
import 'package:Focal/components/today_stats.dart';

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
      cardPosition: MediaQuery.of(context).size.height / 2 - 240,
      backgroundColor: Theme.of(context).primaryColor,
      staticChild: Stack(
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
                    if (_timeFrame != 'today') {
                      setState(() {
                        _loading = true;
                        _timeFrame = 'today';
                      });
                    }
                  },
                  child: Container(
                    height: 30,
                    width: 150,
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
                    width: 150,
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
        ]
      ),
      dynamicChild: Stack(
        children: <Widget>[
          Positioned(
            right: 30,
            left: 30,
            top: MediaQuery.of(context).size.height / 2 - 180,
            child: _timeFrame == 'today' ? TodayStats(callback: () => setState(() => _loading = false)) : Container(),
          ),
        ],
      ),
    );
  }
}
