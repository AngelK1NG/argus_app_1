import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          height: 60,
          minWidth: 60,
        ),
        accentColor: const Color(0xff3c25d7),
      ),
      home: Scaffold(
        body: SizedBox.expand(
          child: HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stopwatch swatch = Stopwatch();
  Timer timer;
  String _swatchDisplay = "00:00";
  String _taskDisplay = "Do your shit";
  double _taskPercent = 0.69;
  bool _doingTask = false;

  void startTask() {
    swatch.start();
    timer = new Timer.periodic(
      const Duration(seconds: 1), (Timer timer) => setState(() {
        _swatchDisplay = swatch.elapsed.inMinutes.toString().padLeft(2, "0") + ":" + (swatch.elapsed.inSeconds%60).toString().padLeft(2, "0");
      })
    );
    setState(() {
      _doingTask = true;
    });
  }

  void stopTask() {
    swatch.stop();
    swatch.reset();
    setState(() {
      _doingTask = false;
      _swatchDisplay = "00:00";
    });
  }

  void abandonTask() {
    swatch.stop();
    swatch.reset();
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
    return Stack(
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 100),
          alignment: Alignment.center,
          color: _doingTask ? Colors.black : Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Text(_swatchDisplay, textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w500,
                  color: _doingTask ? Colors.white : Colors.black,
                ),),
              ),
              Text(_taskDisplay, textAlign: TextAlign.center, style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: _doingTask ? Colors.white : Colors.black,
              ),),
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _doingTask ? HomeButton(onTap: stopTask, buttonColor: Colors.white, buttonText: "Complete") : HomeButton(onTap: startTask, buttonColor: Colors.black, buttonText: "Start",),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: AbandonButton(onTap: abandonTask),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  width: 315,
                  height: 5,
                  child: Visibility(
                    visible: !_doingTask,
                    child: LinearProgressIndicator(
                      value: _taskPercent,
                      backgroundColor: Colors.black,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  alignment: Alignment.centerRight,
                  width: 315,
                  height: 20,
                  child: Visibility(
                    visible: !_doingTask,
                    child: Text(
                      (_taskPercent*100).toInt().toString() + "%",
                      style: TextStyle(fontSize: 20,)
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          child: Offstage(
            offstage: _doingTask,
            child: NavBurger(),
          ),
        ),
      ]
    );
  }
}

class NavBurger extends StatelessWidget {
  const NavBurger({Key key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 50),
      child: IconButton(
        onPressed: () {},
        icon: FaIcon(FontAwesomeIcons.bars, size: 32),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color buttonColor;
  final String buttonText;

  const HomeButton({this.onTap, this.buttonColor, this.buttonText});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: 240,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: this.buttonColor,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Text(this.buttonText, textAlign: TextAlign.center, style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: this.buttonColor == Colors.black ? Colors.white : Colors.black,
        ),),
      ),
    );
  }
}
class AbandonButton extends StatelessWidget {
  final VoidCallback onTap;

  const AbandonButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: FaIcon(FontAwesomeIcons.running, color: Colors.white, size: 32,),
      ),
    );
  }
}