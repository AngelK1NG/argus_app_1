import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/local_notifications.dart';
import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../components/rct_button.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io' show Platform;

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loginLoading = false;
  bool _loading = true;
  bool _isLogin = false;

  @override
  void initState() {
    super.initState();
    auth.onAuthStateChanged.listen((user) {
      if (context != null) {
        Provider.of<User>(context, listen: false).user = user;
      } else {
        user = null;
      }
      if (user == null) {
        if (mounted) {
          setState(() {
            _isLogin = true;
            _loading = false;
          });
        }
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        FirestoreProvider(user).userDocumentExists().then((exists) {
          if (mounted) {
            if (_isLogin) {
              setState(() {
                _loginLoading = false;
              });
              if (exists) {
                Navigator.pushNamed(context, '/home');
              } else {
                Navigator.pushNamed(context, '/onboarding');
              }
            } else {
              Future.delayed(Duration(milliseconds: 500), () {
                setState(() {
                  _loading = false;
                });
                Future.delayed(Duration(milliseconds: 500), () {
                  if (exists) {
                    Navigator.pushNamed(context, '/home');
                  } else {
                    Navigator.pushNamed(context, '/onboarding');
                  }
                });
              });
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
        ),
        Visibility(
          visible: _isLogin,
          child: ModalProgressHUD(
            inAsyncCall: _loginLoading,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                    image:
                        AssetImage('assets/images/logo/Focal Logo_Full.png')),
                Padding(
                  padding: const EdgeInsets.only(top: 180),
                  child: Column(
                    children: <Widget>[
                      RctButton(
                        onTap: () async {
                          setState(() {
                            _loginLoading = true;
                          });
                          dynamic result = await AuthProvider().googleSignIn();
                          if (result == null) {
                            setState(() {
                              _loginLoading = false;
                            });
                          } else {
                            LocalNotificationHelper.userLoggedIn = true;
                            AnalyticsProvider().logGoogleSignIn();
                          }
                        },
                        buttonWidth: 315,
                        gradient: LinearGradient(
                          colors: [Theme.of(context).primaryColor, Theme.of(context).accentColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        buttonText: "Sign in with Google",
                        textSize: 24,
                        icon: FaIcon(
                          FontAwesomeIcons.google,
                          color: Colors.white,
                          size: 30,
                        ),
                        vibrate: true,
                      ),
                      Platform.isIOS
                          ? Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: RctButton(
                                onTap: () async {
                                  setState(() {
                                    _loginLoading = true;
                                  });
                                  dynamic result =
                                      await AuthProvider().appleSignIn();
                                  if (result == null) {
                                    setState(() {
                                      _loginLoading = false;
                                    });
                                  } else {
                                    LocalNotificationHelper.userLoggedIn = true;
                                    AnalyticsProvider().logAppleSignIn();
                                  }
                                },
                                buttonWidth: 315,
                                gradient: LinearGradient(
                                  colors: [jetBlack, jetBlack],
                                ),
                                buttonText: "Sign in with Apple",
                                textSize: 24,
                                icon: FaIcon(
                                  FontAwesomeIcons.apple,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                vibrate: true,
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: !_isLogin,
          child: AnimatedOpacity(
            opacity: _loading ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            child: Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Image(
                  image: AssetImage('assets/images/logo/Focal Logo_Full.png')),
            ),
          ),
        ),
      ],
    );
  }
}
