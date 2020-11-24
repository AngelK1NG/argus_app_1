import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/components/bottom_nav.dart';
import 'package:Focal/components/volts.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'focus.dart';
import 'tasks.dart';
import 'statistics.dart';
import 'profile.dart';
import 'general.dart';
import 'help.dart';
import 'about.dart';
import 'share_statistics.dart';

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _child;
  Color _backgroundColor;
  double _cardPosition = 0;
  bool _showNav = true;
  bool _keyboard = false;
  int _selectedIndex = 0;
  bool _initialized = false;
  bool _loading = false;

  void goToPage(int index) {
    _selectedIndex = index;
    setState(() {
      switch (index) {
        case 0:
          {
            _child = FocusPage(
              goToPage: goToPage,
              setLoading: setLoading,
              setNav: setNav,
              setDoingTask: setDoingTask,
            );
            _cardPosition = SizeConfig.safeBlockVertical * 36;
            setNav(true);
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            break;
          }
        case 1:
          {
            _child = TasksPage(
              goToPage: goToPage,
              setLoading: setLoading,
            );
            _cardPosition = 80;
            setNav(true);
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            break;
          }
        case 2:
          {
            _child = StatisticsPage(
              goToPage: goToPage,
              setLoading: setLoading,
              shareStatistics: shareStatistics,
            );
            _cardPosition = 80;
            setNav(true);
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            break;
          }
        case 3:
          {
            _child = ProfilePage(
              goToPage: goToPage,
              setLoading: setLoading,
            );
            _cardPosition = 80;
            setNav(true);
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            break;
          }
        case 4:
          {
            _child = GeneralPage(goToPage: goToPage);
            _cardPosition = 80;
            setNav(true);
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            break;
          }
        case 5:
          {
            _child = HelpPage(goToPage: goToPage);
            _cardPosition = 0;
            setNav(false);
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
            break;
          }
        case 6:
          {
            _child = AboutPage(goToPage: goToPage);
            _cardPosition = 0;
            setNav(false);
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
            break;
          }
      }
    });
  }

  void setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  void setNav(bool visible) {
    setState(() {
      _showNav = visible;
    });
  }

  void setDoingTask(bool doingTask) {
    if (doingTask) {
      setState(() {
        _cardPosition = SizeConfig.safeBlockVertical * 50;
        _backgroundColor = jetBlack;
        _showNav = false;
      });
    } else {
      setState(() {
        _cardPosition = SizeConfig.safeBlockVertical * 36;
        _backgroundColor = Theme.of(context).primaryColor;
      });
    }
  }

  void shareStatistics({
    Volts volts,
    List<Volts> voltsList,
    num voltsDelta,
    Duration timeFocused,
    int index,
  }) {
    setState(() {
      _child = ShareStatistics(
        goToPage: goToPage,
        volts: volts,
        voltsList: voltsList,
        timeFocused: timeFocused,
        index: index,
      );
      _cardPosition = 0;
      setNav(false);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
  }

  @override
  void initState() {
    super.initState();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          _keyboard = visible;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      SizeConfig().init(context);
      _initialized = true;
    }
    goToPage(_selectedIndex);
    setState(() {
      _backgroundColor = Theme.of(context).primaryColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            color: _backgroundColor,
          ),
          AnimatedPositioned(
            duration: cardDuration,
            curve: cardCurve,
            left: 0,
            right: 0,
            top: _cardPosition == 0
                ? 0
                : _cardPosition + MediaQuery.of(context).padding.top,
            child: AnimatedContainer(
              duration: cardDuration,
              curve: cardCurve,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft:
                      _cardPosition == 0 ? Radius.zero : Radius.circular(40),
                  topRight:
                      _cardPosition == 0 ? Radius.zero : Radius.circular(40),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: -5,
                    blurRadius: 15,
                  )
                ],
              ),
              height: MediaQuery.of(context).size.height,
            ),
          ),
          SafeArea(child: _child),
          SafeArea(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: BottomNav(
                onTap: goToPage,
                show: _showNav && !_keyboard,
                index: _selectedIndex,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              opacity: _loading ? 1 : 0,
              duration: cardDuration,
              curve: cardCurve,
              child: LinearProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
