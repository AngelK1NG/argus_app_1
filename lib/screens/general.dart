import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'dart:io' show Platform;
import 'package:Focal/constants.dart';
import 'package:Focal/components/settings_switch_item.dart';
import 'package:Focal/components/nav_button.dart';

class GeneralPage extends StatefulWidget {
  final Function goToPage;

  GeneralPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _GeneralPageState createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  SharedPreferences _prefs;
  bool _loading = true;
  bool _distractedNotification = true;
  bool _focusDnd = true;

  void getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_prefs.getBool('repeatDistractedNotification') == null) {
        _distractedNotification = true;
        _prefs.setBool('repeatDistractedNotification', true);
      } else {
        _distractedNotification =
            _prefs.getBool('repeatDistractedNotification');
      }
      if (_prefs.getBool('focusDnd') == null) {
        _focusDnd = true;
        _prefs.setBool('focusDnd', true);
      } else {
        _focusDnd = _prefs.getBool('focusDnd');
      }
    });
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void setBool(String key, bool val) async {
    _prefs.setBool(key, val);
    print('$key is set to ${_prefs.get(key)}');
  }

  void setInt(String key, int val) async {
    _prefs.setInt(key, val);
    print('$key is set to ${_prefs.get(key)}');
  }

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.goToPage(2),
      child: Stack(children: <Widget>[
        Container(
          alignment: Alignment.center,
          height: 50,
          child: Text(
            'General',
            style: whiteHeaderTextStyle,
          ),
        ),
        Positioned(
            left: 5,
            top: 0,
            child: NavButton(
              onTap: () {
                widget.goToPage(2);
              },
              iconData: FeatherIcons.chevronLeft,
              color: white,
            )),
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: AnimatedOpacity(
            opacity: _loading ? 0 : 1,
            duration: cardDuration,
            curve: cardCurve,
            child: Column(
              children: <Widget>[
                SettingsSwitchItem(
                  title: 'Repeatedly notify when Distracted',
                  toggle: _distractedNotification,
                  onChanged: (value) {
                    setState(() {
                      _distractedNotification = value;
                    });
                    setBool('repeatDistractedNotification', value);
                  },
                ),
                Platform.isAndroid
                    ? SettingsSwitchItem(
                        title: 'Turn on Do Not Disturb when Focused',
                        toggle: _focusDnd,
                        onChanged: (value) {
                          setState(() {
                            _focusDnd = value;
                          });
                          setBool('focusDnd', value);
                        })
                    : Container(),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
