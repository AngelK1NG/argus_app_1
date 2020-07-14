import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Components/WrapperWidget.dart';
import '../Components/RctButton.dart';
import '../Components/SqrButton.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer timer;
  DateTime _startTime;
  String _swatchDisplay = "00:00";
  String _taskDisplay = "AP Bio Reading U7 p37-39";
  double _taskPercent = 0.69;
  bool _doingTask = false;

  void startTask() {
    timer = new Timer.periodic(
      const Duration(seconds: 1), (Timer timer) => setState(() {
        if (_doingTask) {
          final currentTime = DateTime.now();
          _swatchDisplay = currentTime.difference(_startTime).inMinutes.toString().padLeft(2, "0") + ":" + (currentTime.difference(_startTime).inSeconds % 60).toString().padLeft(2, "0");
        } else {
          timer.cancel();
        }
      })
    );
    setState(() {
      _doingTask = true;
      _startTime = DateTime.now();
    });
  }

  void stopTask() {
    setState(() {
      _doingTask = false;
      _swatchDisplay = "00:00";
    });
  }

  void abandonTask() {
    setState(() {
      _doingTask = false;
      _swatchDisplay = "00:00";
    });
}

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: WrapperWidget(
        nav: !_doingTask,
        backgroundColor: _doingTask ? Colors.black : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
              child: Container(
                width: 315,
                padding: const EdgeInsets.only(bottom: 70),
                child: Text(_swatchDisplay, textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w500,
                  color: _doingTask ? Colors.white : Colors.black,
                ),),
              ),
            ),
            Text(_taskDisplay, textAlign: TextAlign.center, style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: _doingTask ? Colors.white : Colors.black,
            ),),
            Padding(
              padding: const EdgeInsets.only(top: 90),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _doingTask ? RctButton(onTap: stopTask, buttonWidth: 240, buttonText: "Complete", buttonColor: Colors.white, textColor: Colors.black, textSize: 32,) : RctButton(onTap: startTask, buttonWidth: 240, buttonText: "Start", buttonColor: Colors.black, textColor: Colors.white, textSize: 32,),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: SqrButton(onTap: abandonTask, buttonColor: Theme.of(context).primaryColor, icon: FaIcon(FontAwesomeIcons.running, size: 32, color: Colors.white,)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SizedBox(
                width: 315,
                height: 5,
                child: Visibility(
                  visible: !_doingTask,
                  child: LinearProgressIndicator(
                    value: _taskPercent,
                    backgroundColor: Colors.black,                ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Container(
                alignment: Alignment.centerRight,
                width: 315,
                height: 24,
                child: Visibility(
                  visible: !_doingTask,
                  child: Text(
                    (_taskPercent*100).toInt().toString() + "%",
                    style: TextStyle(fontSize: 24,)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}