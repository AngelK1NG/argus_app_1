import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  final Function goToPage;

  StatisticsPage({
    @required this.goToPage,
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
        children: <Widget>[],
      ),
    );
  }
}
