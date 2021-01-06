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
  bool _loginLoading = false;
  AuthProvider auth = AuthProvider();
  DatabaseProvider db = DatabaseProvider();

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
      });
    } else {
      setState(() {
        _loginLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      goToPage(0);
      setState(() {
        _backgroundColor = Theme.of(context).primaryColor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    var user = Provider.of<User>(context);
    var uncompletedTasks = Provider.of<UncompletedTasks>(context).tasks;
    var completedTasks = Provider.of<CompletedTasks>(context).tasks;
    print((user != null && user.signedIn == true) &&
        (uncompletedTasks == null || completedTasks == null));
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
                  opacity: user == null ||
                          ((user != null && user.signedIn == true) &&
                              (uncompletedTasks == null ||
                                  completedTasks == null))
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
                              (user != null && !user.signedIn ||
                                  uncompletedTasks == null ||
                                  completedTasks == null)
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
                        child: (user != null &&
                                user.signedIn &&
                                uncompletedTasks != null &&
                                completedTasks != null)
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
                  opacity: user == null ||
                          ((user != null && user.signedIn == true) &&
                              (uncompletedTasks == null ||
                                  completedTasks == null)) ||
                          _loginLoading
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
