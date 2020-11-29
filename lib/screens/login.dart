import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../components/rct_button.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:url_launcher/url_launcher.dart';
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
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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
                Navigator.pushNamed(context, '/onboardingIntro');
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
                    Navigator.pushNamed(context, '/onboardingIntro');
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Stack(
              children: [
                Visibility(
                  visible: _isLogin,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage(
                              'assets/images/logo/Focal Logo_Full Colored.png'),
                          width: 300,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 180),
                          child: RctButton(
                            onTap: () async {
                              setState(() {
                                _loginLoading = true;
                              });
                              dynamic result =
                                  await AuthProvider().googleSignIn();
                              if (result == null) {
                                setState(() {
                                  _loginLoading = false;
                                });
                              } else {
                                AnalyticsProvider().logGoogleSignIn();
                              }
                            },
                            buttonWidth: 300,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).accentColor
                              ],
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
                                      AnalyticsProvider().logAppleSignIn();
                                    }
                                  },
                                  buttonWidth: 300,
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
                            : Container(),
                        Container(
                          padding: EdgeInsets.only(top: 25),
                          width: 300,
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'By continuing you agree to Focal\'s ',
                                ),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => openUrl(
                                        'https://docs.google.com/document/d/1h0fBpGKMKHna0MSA8NTt0FXAdc551ALwSkVWJkh0mbY/edit?usp=sharing'),
                                ),
                                TextSpan(
                                  text: ' and ',
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => openUrl(
                                        'https://docs.google.com/document/d/1eIL0fXCFXXoiIfU59qPXqnQxhKp-8VG2XTvh63O0d-o/edit?usp=sharing'),
                                ),
                                TextSpan(
                                  text: '.',
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
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
                    child: Center(
                      child: Image(
                        image: AssetImage(
                            'assets/images/logo/Focal Logo_Full Colored.png'),
                        width: 300,
                      ),
                    ),
                  ),
                ),
              ],
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
    );
  }
}
