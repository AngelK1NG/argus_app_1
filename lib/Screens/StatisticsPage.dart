import 'package:flutter/material.dart';
import '../Components/WrapperWidget.dart';

class StatisticsPage extends StatefulWidget {
  StatisticsPage({Key key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Duration _timeSpent = Duration(seconds: 6969);
  double _taskPercent = 0.69;
  int _tasksDone = 3;

  @override
  Widget build(BuildContext context) {
    return WrapperWidget(
      nav: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
            child: Container(
              width: 315,
              padding: const EdgeInsets.only(bottom: 70),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: _timeSpent.inHours.toString().padLeft(2, "0") + ":" +(_timeSpent.inMinutes % 60).toString().padLeft(2, "0") + ":" + (_timeSpent.inSeconds % 60).toString().padLeft(2, "0"),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: ' Spent', style: TextStyle(fontWeight: FontWeight.w300)),
                  ]
                ),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  value: _taskPercent,
                  backgroundColor: Colors.black,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    (_taskPercent*100).toInt().toString(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                  Text(
                    "%",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                    )
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
            child: Container(
              width: 315,
              padding: const EdgeInsets.only(top: 70),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: _tasksDone.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: ' Tasks Completed', style: TextStyle(fontWeight: FontWeight.w300)),
                  ]
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}