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

import 'package:provider/provider.dart';

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
  bool _overlayLight = true;

  void goToPage(int index) {
    setState(() {
      switch (index) {
        case 0:
          {
            _child = TasksPage(
              goToPage: goToPage,
            );
            _cardPosition = 50;
            _overlayLight = true;
            break;
          }
        case 1:
          {
            _child = StatisticsPage(
              goToPage: goToPage,
            );
            _cardPosition = 80;
            _overlayLight = true;
            break;
          }

        case 2:
          {
            _child = SettingsPage(
              goToPage: goToPage,
            );
            _cardPosition = 50;
            _overlayLight = true;
            break;
          }
        case 3:
          {
            _child = FocusPage(
              goToPage: goToPage,
            );
            _cardPosition = SizeConfig.safeHeight;
            _overlayLight = true;
            break;
          }

        case 4:
          {
            _child = GeneralPage(goToPage: goToPage);
            _cardPosition = 50;
            _overlayLight = true;
            break;
          }
        case 5:
          {
            _child = HelpPage(goToPage: goToPage);
            _cardPosition = 0;
            _overlayLight = false;
            break;
          }
        case 6:
          {
            _child = AboutPage(goToPage: goToPage);
            _cardPosition = 0;
            _overlayLight = false;
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

  bool _loading(UserStatus user, List uncompletedTasks, List completedTasks) {
    return user == null ||
        ((user != null && user.signedIn) &&
            (uncompletedTasks == null || completedTasks == null));
  }

  bool _signedIn(UserStatus user) {
    return user != null && user.signedIn;
  }

  bool _signedOut(UserStatus user) {
    return user != null && !user.signedIn;
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
    var user = Provider.of<UserStatus>(context);
    var uncompletedTasks = Provider.of<UncompletedTasks>(context).tasks;
    var completedTasks = Provider.of<CompletedTasks>(context).tasks;
    return AnnotatedRegion(
      value: (_signedOut(user) || !_overlayLight)
          ? SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
            )
          : SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            AnimatedOpacity(
              opacity: _loading(user, uncompletedTasks, completedTasks) ? 0 : 1,
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
                          _signedOut(user) ||
                          _loading(user, uncompletedTasks, completedTasks)
                      ? 0
                      : _cardPosition + MediaQuery.of(context).padding.top,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: _cardPosition == 0 ||
                                _signedOut(user) ||
                                _loading(user, uncompletedTasks, completedTasks)
                            ? Radius.zero
                            : Radius.circular(25),
                        topRight: _cardPosition == 0 ||
                                _signedOut(user) ||
                                _loading(user, uncompletedTasks, completedTasks)
                            ? Radius.zero
                            : Radius.circular(25),
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
                    child: _signedIn(user) &&
                            !_loading(user, uncompletedTasks, completedTasks)
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
              opacity: _loading(user, uncompletedTasks, completedTasks) ||
                      _loginLoading
                  ? 1
                  : 0,
              duration: generalDuration,
              curve: generalCurve,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
