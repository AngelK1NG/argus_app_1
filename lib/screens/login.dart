import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vivi/constants.dart';
import 'package:vivi/components/button.dart';
import 'package:vivi/components/nav.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/utils/auth.dart';
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
        children: [
          AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: loginDuration,
            curve: loginCurve,
            child: Nav(
              title: 'Welcome 👋',
            ),
          ),
          AnimatedPositioned(
            duration: loginDuration,
            curve: loginCurve,
            left: 50,
            right: 50,
            top: _visible
                ? SizeProvider.safeHeight * 0.25
                : SizeProvider.safeHeight * 0.5,
            child: Image(
              image: AssetImage('assets/images/Logo Large Light.png'),
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
                                widget.setLoading(
                                    loading: false, success: true);
                                widget.goToPage(0);
                              } else {
                                widget.setLoading(
                                    loading: false, success: false);
                              }
                            },
                            width: SizeProvider.safeWidth - 100,
                            color: Theme.of(context).primaryColor,
                            row: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 15),
                                  child: FaIcon(
                                    FontAwesomeIcons.apple,
                                    color: Theme.of(context).backgroundColor,
                                    size: 20,
                                  ),
                                ),
                                Text(
                                  'Sign in with Apple',
                                  style: buttonTextStyle.apply(
                                    color: Theme.of(context).backgroundColor,
                                  ),
                                ),
                              ],
                            ),
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
                          widget.setLoading(loading: false, success: true);
                          widget.goToPage(0);
                        } else {
                          widget.setLoading(loading: false, success: false);
                        }
                      },
                      width: SizeProvider.safeWidth - 100,
                      color: Theme.of(context).accentColor,
                      row: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: FaIcon(
                              FontAwesomeIcons.google,
                              color: white,
                              size: 20,
                            ),
                          ),
                          Text(
                            'Sign in with Google',
                            style: buttonTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
