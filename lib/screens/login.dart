import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/button.dart';
import 'package:Focal/components/nav.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/utils/auth.dart';
import 'dart:io' show Platform;

class LoginPage extends StatefulWidget {
  final Function goToPage;
  final Function setLoading;

  const LoginPage({@required this.goToPage, @required this.setLoading, Key key})
      : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _visible = false;

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
    Future.delayed(Duration.zero, () {
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: loginDuration,
      curve: loginCurve,
      child: Stack(
        children: <Widget>[
          AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: loginDuration,
            curve: loginCurve,
            child: Nav(
              title: 'Welcome 👋',
              color: Colors.black,
            ),
          ),
          AnimatedPositioned(
            duration: loginDuration,
            curve: loginCurve,
            left: 50,
            right: 50,
            top: _visible
                ? SizeConfig.safeHeight * 0.3
                : SizeConfig.safeHeight * 0.5,
            child: Image(
              image: AssetImage('assets/images/Focal Logo_Full Colored.png'),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 50,
            right: 50,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: loginDuration,
              curve: loginCurve,
              child: Column(
                children: [
                  Platform.isIOS
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Button(
                            onTap: () async {
                              widget.setLoading(loading: true);
                              dynamic result =
                                  await AuthProvider().appleSignIn();
                              if (result != null) {
                                AnalyticsProvider().logAppleSignIn();
                                widget.setLoading(
                                    loading: false, success: true);
                                widget.goToPage(0);
                              } else {
                                widget.setLoading(
                                    loading: false, success: false);
                              }
                            },
                            width: SizeConfig.safeWidth - 100,
                            gradient: LinearGradient(
                              colors: [black, black],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            row: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 15),
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
                        widget.setLoading(loading: true);
                        dynamic result = await AuthProvider().googleSignIn();
                        if (result != null) {
                          AnalyticsProvider().logGoogleSignIn();
                          widget.setLoading(loading: false, success: true);
                          widget.goToPage(0);
                        } else {
                          widget.setLoading(loading: false, success: false);
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 15),
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
                            text: 'By continuing you agree to Focal\'s ',
                          ),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap =
                                  () => openUrl('https://getfocal.app/terms'),
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
                              ..onTap =
                                  () => openUrl('https://getfocal.app/privacy'),
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
        ],
      ),
    );
  }
}
