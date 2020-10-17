import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/components/bottom_nav.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'focus.dart';
import 'tasks.dart';
import 'statistics.dart';
import 'profile.dart';
import 'general.dart';
import 'help.dart';
import 'about.dart';

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
  int _selectedIndex = 0;
  bool _initialized = false;

  void setDoingTask(doingTask) {
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
        _showNav = true;
      });
    }
  }

  void setNav(visible) {
    setState(() {
      _showNav = visible;
    });
  }

  void goToPage(int index) {
    _selectedIndex = index;
    setState(() {
      switch (index) {
        case 0:
          {
            _child = FocusPage(goToPage: goToPage, setDoingTask: setDoingTask);
            _cardPosition = SizeConfig.safeBlockVertical * 36;
            setNav(true);
            break;
          }
        case 1:
          {
            _child = TasksPage(goToPage: goToPage);
            _cardPosition = SizeConfig.safeBlockVertical * 15;
            setNav(true);
            break;
          }
        case 2:
          {
            _child = StatisticsPage(goToPage: goToPage);
            _cardPosition = SizeConfig.safeBlockVertical * 15;
            setNav(true);
            break;
          }
        case 3:
          {
            _child = ProfilePage(goToPage: goToPage);
            _cardPosition = SizeConfig.safeBlockVertical * 15;
            setNav(true);
            break;
          }
        case 4:
          {
            _child = GeneralPage(goToPage: goToPage);
            _cardPosition = SizeConfig.safeBlockVertical * 15;
            setNav(true);
            break;
          }
        case 5:
          {
            _child = HelpPage(goToPage: goToPage);
            _cardPosition = 0;
            setNav(false);
            break;
          }
        case 6:
          {
            _child = AboutPage(goToPage: goToPage);
            _cardPosition = 0;
            setNav(false);
            break;
          }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (mounted) {
        setNav(!visible);
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
            duration: cardSlideDuration,
            curve: cardSlideCurve,
            left: 0,
            right: 0,
            top: _cardPosition == 0 ? 0 : _cardPosition + MediaQuery.of(context).padding.top,
            child: AnimatedContainer(
              duration: cardSlideDuration,
              curve: cardSlideCurve,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: _cardPosition == 0 ? Radius.zero : Radius.circular(40),
                  topRight: _cardPosition == 0 ? Radius.zero : Radius.circular(40),
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
                show: _showNav,
                index: _selectedIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
