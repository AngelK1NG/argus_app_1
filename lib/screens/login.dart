import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:Focal/constants.dart';
import 'package:Focal/components/button.dart';
import 'package:Focal/screens/home.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _initialized = false;
  bool _loginLoading = false;
  bool _login = false;
  bool _visible = true;
  bool _signedIn = false;
  bool _first = true;
  FirebaseUser _user;

  void openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Couldn\'t find url');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      SizeConfig().init(context);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: AuthProvider().onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (_user != snapshot.data || _first) {
            _first = false;
            _user = snapshot.data;
            Future.delayed(Duration.zero, () {
              Provider.of<User>(context, listen: false).user = _user;
              if (_user == null) {
                setState(() {
                  _login = true;
                  _visible = true;
                  _signedIn = false;
                });
              } else {
                setState(() {
                  _visible = false;
                  _loginLoading = false;
                });
                Future.delayed(loginDuration, () {
                  if (_user != null) {
                    setState(() {
                      _signedIn = true;
                    });
                  }
                });
              }
            });
          }
        }
        if (_signedIn) {
          return Home();
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            body: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: loginDuration,
              curve: loginCurve,
              child: Stack(
                children: <Widget>[
                  SafeArea(
                    child: SizedBox.expand(
                      child: Stack(
                        children: [
                          AnimatedOpacity(
                            opacity: _login && _visible ? 1 : 0,
                            duration: loginDuration,
                            curve: loginCurve,
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              child: Text(
                                'Welcome 👋 ',
                                style: blackHeaderTextStyle,
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: loginDuration,
                            curve: loginCurve,
                            left: 50,
                            right: 50,
                            top: _login
                                ? SizeConfig.safeHeight * 0.5 -
                                    (SizeConfig.safeWidth - 100) * 0.4
                                : SizeConfig.safeHeight * 0.5 -
                                    (SizeConfig.safeWidth - 100) * 0.2,
                            child: Image(
                              image: AssetImage(
                                  'assets/images/logo/Focal Logo_Full Colored.png'),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 50,
                            right: 50,
                            child: Offstage(
                              offstage: !_login,
                              child: AnimatedOpacity(
                                opacity: _login && _visible ? 1 : 0,
                                duration: loginDuration,
                                curve: loginCurve,
                                child: Column(
                                  children: [
                                    Platform.isIOS
                                        ? Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 15),
                                            child: Button(
                                              onTap: () async {
                                                setState(() {
                                                  _loginLoading = true;
                                                });
                                                dynamic result =
                                                    await AuthProvider()
                                                        .appleSignIn();
                                                if (result == null) {
                                                  setState(() {
                                                    _loginLoading = false;
                                                  });
                                                } else {
                                                  AnalyticsProvider()
                                                      .logAppleSignIn();
                                                }
                                              },
                                              width: SizeConfig.safeWidth - 100,
                                              gradient: LinearGradient(
                                                colors: [black, black],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              row: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 15),
                                                    child: FaIcon(
                                                      FontAwesomeIcons.apple,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Sign in with Apple',
                                                    style: buttonTextStyle,
                                                  ),
                                                ],
                                              ),
                                              vibrate: true,
                                            ),
                                          )
                                        : Container(),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Button(
                                        onTap: () async {
                                          setState(() {
                                            _loginLoading = true;
                                          });
                                          dynamic result = await AuthProvider()
                                              .googleSignIn();
                                          if (result == null) {
                                            setState(() {
                                              _loginLoading = false;
                                            });
                                          } else {
                                            AnalyticsProvider()
                                                .logGoogleSignIn();
                                          }
                                        },
                                        width: SizeConfig.safeWidth - 100,
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context).primaryColorLight,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        row: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 15),
                                              child: FaIcon(
                                                FontAwesomeIcons.google,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            Text(
                                              'Sign in with Google',
                                              style: buttonTextStyle,
                                            ),
                                          ],
                                        ),
                                        vibrate: true,
                                      ),
                                    ),
                                    Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: Text.rich(
                                        TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  'By continuing you agree to Focal\'s ',
                                            ),
                                            TextSpan(
                                              text: 'Terms and Conditions',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () => openUrl(
                                                    'https://getfocal.app/terms'),
                                            ),
                                            TextSpan(
                                              text: ' and ',
                                            ),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () => openUrl(
                                                    'https://getfocal.app/privacy'),
                                            ),
                                            TextSpan(
                                              text: '.',
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedOpacity(
                      opacity: _loginLoading ? 1 : 0,
                      duration: cardDuration,
                      curve: cardCurve,
                      child: LinearProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
