import 'package:Focal/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/rct_button.dart';
import '../components/sqr_button.dart';
import '../constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/user.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingFocus extends StatefulWidget {
  OnboardingFocus({Key key}) : super(key: key);

  @override
  _OnboardingFocusState createState() => _OnboardingFocusState();
}

class _OnboardingFocusState extends State<OnboardingFocus> {
  int _index = 0;
  String _title;
  Text _text;

  TextStyle descriptionStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  void setText() {
    switch (_index) {
      case 1:
        {
          setState(() {
            _title = 'Focus Mode';
            _text = Text.rich(
              TextSpan(
                style: descriptionStyle,
                children: [
                  TextSpan(
                    text:
                        'This is where you will complete your tasks 📋. You can remain ',
                  ),
                  TextSpan(
                    text: 'Focused',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  TextSpan(
                    text: ' by staying on Focal or locking your phone 🔒.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            );
          });
          break;
        }
      case 2:
        {
          setState(() {
            _title = 'Distractions';
            _text = Text.rich(
              TextSpan(
                style: descriptionStyle,
                children: [
                  TextSpan(
                    text:
                        'When you leave the app while completing a task, you become ',
                  ),
                  TextSpan(
                    text: 'Distracted',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  TextSpan(
                    text:
                        '. You will be notified 🔔 and receive a Volts penalty 🛑.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            );
          });
          break;
        }
      case 3:
        {
          setState(() {
            _title = 'Pause';
            _text = Text.rich(
              TextSpan(
                style: descriptionStyle,
                children: [
                  TextSpan(
                    text: 'To pause a task, tap ',
                  ),
                  WidgetSpan(
                      child: Icon(
                    Icons.pause,
                    size: 24,
                    color: Colors.white,
                  )),
                  TextSpan(
                    text:
                        '. Your time will be saved so you can return where you left off 💾.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            );
          });
          break;
        }
      case 4:
        {
          setState(() {
            _title = 'Need to use your phone?';
            _text = Text.rich(
              TextSpan(
                style: descriptionStyle,
                children: [
                  TextSpan(
                    text: 'If your task requires you to use your phone, tap ',
                  ),
                  WidgetSpan(
                      child: Icon(
                    FeatherIcons.logOut,
                    size: 24,
                    color: Colors.white,
                  )),
                  TextSpan(
                    text: ' to leave Focal and remain ',
                  ),
                  TextSpan(
                    text: 'Focused',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  TextSpan(
                    text: '.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            );
          });
          break;
        }
      case 5:
        {
          setState(() {
            _title = 'All done?';
            _text = Text.rich(
              TextSpan(
                style: descriptionStyle,
                children: [
                  TextSpan(
                    text: 'When you are done with your task, tap ',
                  ),
                  TextSpan(
                    text: 'Done',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  TextSpan(
                    text: ' to complete it ✅.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            );
          });
          break;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SizeConfig().init(context);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle topTextStyle = TextStyle(
      fontSize: 36,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    TextStyle taskTextStyle = TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async => false,
        child: Stack(
          children: <Widget>[
            Container(
              color: _index == 0 ? Theme.of(context).primaryColor : jetBlack,
            ),
            AnimatedPositioned(
              duration: cardDuration,
              curve: cardCurve,
              left: 0,
              right: 0,
              top: _index == 0
                  ? SizeConfig.safeBlockVertical * 36 +
                      MediaQuery.of(context).padding.top
                  : SizeConfig.safeBlockVertical * 50 +
                      MediaQuery.of(context).padding.top,
              child: AnimatedContainer(
                duration: cardDuration,
                curve: cardCurve,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
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
              child: Stack(
                children: [
                  Positioned(
                    left: 17,
                    top: 17,
                    child: AnimatedOpacity(
                      opacity: _index == 0 ? 0 : 1,
                      duration: cardDuration,
                      curve: cardCurve,
                      child: GestureDetector(
                        onTap: () {
                          if (_index > 0) {
                            HapticFeedback.heavyImpact();
                            setState(() {
                              _index--;
                            });
                            setText();
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          color: Colors.transparent,
                          child: Center(
                            child: Icon(
                              FeatherIcons.chevronLeft,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 17,
                    top: 17,
                    child: AnimatedOpacity(
                      opacity: _index == 4 ? 1 : 0,
                      duration: cardDuration,
                      curve: cardCurve,
                      child: Container(
                        width: 40,
                        height: 40,
                        color: Colors.transparent,
                        child: Center(
                          child: Icon(
                            FeatherIcons.logOut,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 40,
                    right: 40,
                    top: SizeConfig.safeBlockVertical * 12,
                    child: _index == 0
                        ? Container(
                            alignment: Alignment.center,
                            height: SizeConfig.safeBlockVertical * 15,
                            child: AutoSizeText(
                              'Tap Start to enter Focus Mode! 🚀',
                              textAlign: TextAlign.center,
                              style: topTextStyle,
                              maxLines: 2,
                            ),
                          )
                        : Container(
                            alignment: Alignment.center,
                            height: SizeConfig.safeBlockVertical * 25,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  _title,
                                  textAlign: TextAlign.center,
                                  style: topTextStyle,
                                ),
                                _text,
                              ],
                            ),
                          ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: SizeConfig.safeBlockVertical * 50 - 30,
                    child: AnimatedOpacity(
                      duration: cardDuration,
                      curve: cardCurve,
                      opacity: _index == 3 ? 1 : 0,
                      child: Center(
                        child: SqrButton(
                          onTap: () {},
                          icon: Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 24,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          vibrate: false,
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: cardDuration,
                    curve: cardCurve,
                    left: 40,
                    right: 40,
                    top: _index == 0
                        ? SizeConfig.safeBlockVertical * 42
                        : SizeConfig.safeBlockVertical * 56,
                    child: Container(
                      alignment: Alignment.center,
                      height: SizeConfig.safeBlockVertical * 20,
                      child: AutoSizeText(
                        'Welcome to Focal!',
                        textAlign: TextAlign.center,
                        style: taskTextStyle,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: cardDuration,
                    curve: cardCurve,
                    left: 0,
                    right: 0,
                    top: _index == 0
                        ? SizeConfig.safeBlockVertical * 70
                        : SizeConfig.safeBlockVertical * 84,
                    child: Center(
                      child: RctButton(
                        onTap: () {
                          if (_index < 5) {
                            setState(() {
                              _index++;
                            });
                            setText();
                          } else {
                            FirebaseUser user =
                                Provider.of<User>(context, listen: false).user;
                            FirestoreProvider(user).createUserDocument();
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                        buttonWidth: 220,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        buttonText: _index == 0
                            ? 'Start'
                            : _index == 5
                                ? 'Done'
                                : 'Next',
                        textSize: 32,
                        vibrate: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
