import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/utils/auth.dart';
import 'package:vivi/utils/database.dart';
import 'package:vivi/screens/alarms.dart';
import 'package:vivi/screens/settings.dart';
import 'package:vivi/screens/login.dart';
import 'package:vivi/constants.dart';

import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _child;
  bool _loginLoading = false;
  bool _init = false;

  void goToPage(int index) {
    setState(() {
      switch (index) {
        case 0:
          {
            _child = AlarmsPage(goToPage: goToPage);
            break;
          }
        case 1:
          {
            _child = SettingsPage(goToPage: goToPage);
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

  bool _loading(UserStatus user, List completed) {
    return user == null ||
        ((user != null && user.signedIn) && completed == null);
  }

  bool _signedIn(UserStatus user) {
    return user != null && user.signedIn;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      goToPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_init) {
      SizeProvider().init(context);
      _init = true;
    }
    var user = Provider.of<UserStatus>(context);
    var completedTasks = Provider.of<CompletedTasks>(context).tasks;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Theme.of(context).backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color(0xffa6dae8),
              Color(0xffdce5e8),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              AnimatedOpacity(
                opacity: _loading(user, completedTasks) ? 0 : 1,
                duration: fadeDuration,
                curve: fadeCurve,
                child: SafeArea(
                  child: SizedBox.expand(
                    child: _signedIn(user) && !_loading(user, completedTasks)
                        ? _child
                        : LoginPage(
                            goToPage: goToPage,
                            setLoading: setLoginLoading,
                          ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity:
                    _loading(user, completedTasks) || _loginLoading ? 1 : 0,
                duration: fadeDuration,
                curve: fadeCurve,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
