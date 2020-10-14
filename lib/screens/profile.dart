import 'package:Focal/constants.dart';
import 'package:Focal/components/settings_tile.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class ProfilePage extends StatefulWidget {
  final Function goToPage;
  
  ProfilePage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  bool _distractedNotification = true;
  bool _focusDnd = true;

  void getPrefs() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      setState(() {
        if (prefs.getBool('distractedNotification') == null) {
          _distractedNotification = true;
          prefs.setBool('distractedNotification', true);
        } else {
          _distractedNotification = prefs.getBool('distractedNotification');
        }
        if (prefs.getBool('focusDnd') == null) {
          _focusDnd = true;
          prefs.setBool('focusDnd', true);
        } else {
          _focusDnd = prefs.getBool('focusDnd');
        }
      });
      Future.delayed(cardSlideDuration, () {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      });
    });
  }

  void setValue(String key, bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, val);
    print('$key is set to ${prefs.get(key)}');
  }

  openPrivacyPolicy() async {
    const URL =
        'https://docs.google.com/document/d/1eIL0fXCFXXoiIfU59qPXqnQxhKp-8VG2XTvh63O0d-o/edit?usp=sharing';
    if (await canLaunch(URL)) {
      await launch(URL);
    } else {
      print('Couldn\'t find url');
    }
  }

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  @override
  Widget build(BuildContext context) {
    String _email = Provider.of<User>(context, listen: false).user.email;
    return WillPopScope(
      onWillPop: () async => widget.goToPage(0),
      child: Stack(children: <Widget>[
        Positioned(
          left: 25,
          top: SizeConfig.safeBlockVertical * 5,
          child: Text(
            'Profile',
            style: headerTextStyle,
          ),
        ),
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: loadingDuration,
          curve: loadingCurve,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 25,
                left: 25,
                top: SizeConfig.safeBlockVertical * 15 + 40,
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 25),
                        child: Text(
                          'Notifications',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SettingsTile(
                        title: 'Notify when Distracted',
                        toggle: _distractedNotification,
                        onChanged: (value) {
                          setState(() {
                            _distractedNotification = value;
                          });
                          setValue('distractedNotification', value);
                        },
                      ),
                      Platform.isAndroid
                          ? SettingsTile(
                              title: 'Turn on Do Not Disturb when Focused',
                              toggle: _focusDnd,
                              onChanged: (value) {
                                setState(() {
                                  _focusDnd = value;
                                });
                                setValue('focusDnd', value);
                              })
                          : Container(),
                    ])),
              ),
              _email == null
                  ? Container()
                  : Positioned(
                      right: 25,
                      left: 25,
                      bottom: 160,
                      child: Text(
                        "You are signed in as " + _email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
              Positioned(
                right: 25,
                left: 25,
                bottom: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        auth.signOut();
                        AnalyticsProvider().logSignOut();
                      },
                      child: Text("Sign out",
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                          )),
                    ),
                    FlatButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        openPrivacyPolicy();
                      },
                      child: Text("Privacy policy",
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w400,
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
