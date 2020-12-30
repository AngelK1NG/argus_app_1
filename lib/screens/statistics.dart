import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';

class StatisticsPage extends StatefulWidget {
  final Function goToPage;
  final Function setLoading;

  StatisticsPage({
    @required this.goToPage,
    @required this.setLoading,
    Key key,
  }) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.goToPage(0),
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: 50,
            child: Text(
              'Statistics',
              style: whiteHeaderTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
