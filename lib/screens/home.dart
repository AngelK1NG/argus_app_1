import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/components/bottom_nav.dart';
import 'focus.dart';
import 'tasks.dart';
import 'statistics.dart';
import 'profile.dart';

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _child;
  Color _backgroundColor;
  double _cardPosition;
  bool _showNav = true;
  int _selectedIndex = 0;
  bool _initialized = false;

  void toggleDoingTask() {
    if (_cardPosition == SizeConfig.safeBlockVertical * 36) {
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

  void goToPage(int index) {
    _selectedIndex = index;
    setState(() {
      switch (index) {
        case 0:
          _child =
              FocusPage(toggleDoingTask: toggleDoingTask, goToPage: goToPage);
          _cardPosition = SizeConfig.safeBlockVertical * 36;
          break;
        case 1:
          _child = TasksPage();
          _cardPosition = SizeConfig.safeBlockVertical * 15;
          break;
        case 2:
          _child = StatisticsPage();
          _cardPosition = SizeConfig.safeBlockVertical * 15;
          break;
        case 3:
          _child = ProfilePage();
          _cardPosition = SizeConfig.safeBlockVertical * 15;
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _child = FocusPage(toggleDoingTask: toggleDoingTask, goToPage: goToPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      SizeConfig().init(context);
      _initialized = true;
    }
    setState(() {
      _backgroundColor = Theme.of(context).primaryColor;
      switch (_selectedIndex) {
        case 0:
          _child =
              FocusPage(toggleDoingTask: toggleDoingTask, goToPage: goToPage);
          _cardPosition = SizeConfig.safeBlockVertical * 36;
          break;
        case 1:
          _child = TasksPage();
          _cardPosition = SizeConfig.safeBlockVertical * 15;
          break;
        case 2:
          _child = StatisticsPage();
          _cardPosition = SizeConfig.safeBlockVertical * 15;
          break;
        case 3:
          _child = ProfilePage();
          _cardPosition = SizeConfig.safeBlockVertical * 15;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
          child: BottomNav(
              onTap: goToPage, show: _showNav, index: _selectedIndex)),
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
            top: _cardPosition == null
                ? MediaQuery.of(context).size.height
                : _cardPosition + MediaQuery.of(context).padding.top,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
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
        ],
      ),
    );
  }
}
