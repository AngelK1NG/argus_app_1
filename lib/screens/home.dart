import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/database.dart';
import 'package:Focal/screens/focus.dart';
import 'package:Focal/screens/tasks.dart';
import 'package:Focal/screens/statistics.dart';
import 'package:Focal/screens/settings.dart';
import 'package:Focal/screens/general.dart';
import 'package:Focal/screens/help.dart';
import 'package:Focal/screens/about.dart';
import 'package:Focal/screens/login.dart';
import 'package:Focal/constants.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'dart:math';

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _child;
  Color _backgroundColor;
  double _cardPosition = 0;
  bool _loading = true;
  bool _loginLoading = false;
  String _quote = '';
  Random _random = Random();
  AuthProvider auth = AuthProvider();
  DatabaseProvider db = DatabaseProvider();
  final _quotes = [
    '''“You can waste your lives drawing lines. Or you can live your life crossing them.” - Shonda Rhimes''',
    '''“Everything comes to him who hustles while he waits.” - Thomas Edison''',
    '''"The only difference between ordinary and extraordinary is that little extra." - Jimmy Johnson''',
    '''"The secret of getting ahead is getting started." - Mark Twain''',
    '''"The way to get started is to quit talking and begin doing." - Walt Disney''',
    '''"Do you want to know who you are? Don't ask. Act! Action will delineate and define you." - Thomas Jefferson''',
    '''“It’s not knowing what to do, it’s doing what you know.” - Tony Robbins''',
    '''“The big secret in life is that there is no big secret. Whatever your goal, you can get there if you’re willing to work.” - Oprah Winfrey''',
    '''“Action is the foundational key to all success.” - Pablo Picasso''',
    '''“Amateurs sit and wait for inspiration, the rest of us just get up and go to work.” - Stephen King''',
  ];

  void goToPage(int index) {
    setState(() {
      switch (index) {
        case 0:
          {
            _child = TasksPage(
              goToPage: goToPage,
            );
            _cardPosition = 50;
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            break;
          }
        case 1:
          {
            _child = StatisticsPage(
              goToPage: goToPage,
            );
            _cardPosition = 80;
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            break;
          }

        case 2:
          {
            _child = SettingsPage(
              goToPage: goToPage,
            );
            _cardPosition = 50;
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            break;
          }
        case 3:
          {
            _child = FocusPage(
              goToPage: goToPage,
            );
            _cardPosition = SizeConfig.safeHeight;
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            break;
          }

        case 4:
          {
            _child = GeneralPage(goToPage: goToPage);
            _cardPosition = 50;
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
            break;
          }
        case 5:
          {
            _child = HelpPage(goToPage: goToPage);
            _cardPosition = 0;
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
            break;
          }
        case 6:
          {
            _child = AboutPage(goToPage: goToPage);
            _cardPosition = -25;
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
            break;
          }
      }
    });
  }

  void setLoginLoading({@required bool loading, bool success}) {
    if (loading) {
      setState(() {
        _loginLoading = true;
        _loading = true;
        _quote = _quotes[_random.nextInt(_quotes.length)];
      });
    } else {
      if (success) {
        setState(() {
          _loginLoading = false;
        });
        Future.delayed(loadingDelay, () {
          setState(() {
            _loading = false;
          });
        });
      } else {
        setState(() {
          _loginLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _quote = _quotes[_random.nextInt(_quotes.length)];
    Future.delayed(Duration.zero, () {
      goToPage(0);
      setState(() {
        _backgroundColor = Theme.of(context).primaryColor;
      });
    });
    Future.delayed(loadingDelay, () {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    var user = Provider.of<User>(context);
    var uncompletedTasks = Provider.of<UncompletedTasks>(context);
    var completedTasks = Provider.of<CompletedTasks>(context);
    return KeyboardVisibilityProvider(
      child: KeyboardDismissOnTap(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowGlow();
            return null;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: <Widget>[
                AnimatedOpacity(
                  opacity: ((user == null) ||
                          (uncompletedTasks == null) ||
                          (completedTasks == null) ||
                          _loading)
                      ? 0
                      : 1,
                  duration: generalDuration,
                  curve: generalCurve,
                  child: Stack(children: <Widget>[
                    Container(
                      color: _backgroundColor,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _cardPosition == 0 ||
                              (user != null && !user.signedIn)
                          ? 0
                          : _cardPosition + MediaQuery.of(context).padding.top,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
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
                    SafeArea(
                      child: SizedBox.expand(
                        child: (user != null && user.signedIn)
                            ? _child
                            : LoginPage(
                                goToPage: goToPage,
                                setLoading: setLoginLoading,
                              ),
                      ),
                    ),
                  ]),
                ),
                AnimatedOpacity(
                  opacity: ((user == null) ||
                          (uncompletedTasks == null) ||
                          (completedTasks == null) ||
                          _loading && !_loginLoading)
                      ? 1
                      : 0,
                  duration: generalDuration,
                  curve: generalCurve,
                  child: Container(
                    padding: EdgeInsets.all(50),
                    alignment: Alignment.center,
                    child: Text(
                      _quote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: ((user == null) ||
                          (uncompletedTasks == null) ||
                          (completedTasks == null) ||
                          _loading ||
                          _loginLoading)
                      ? 1
                      : 0,
                  duration: generalDuration,
                  curve: generalCurve,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GradientProgressIndicator(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColorLight,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
