import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'dart:io' show Platform;
import 'package:Focal/components/switch_item.dart';
import 'package:Focal/components/nav.dart';

class GeneralPage extends StatefulWidget {
  final Function goToPage;

  GeneralPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _GeneralPageState createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  SharedPreferences _prefs;
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
      child: Column(
        children: [
          Nav(
            title: 'General',
            leftIconData: FeatherIcons.chevronLeft,
            leftOnTap: () {
              widget.goToPage(2);
            },
          ),
          Column(
            children: [
              SwitchItem(
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
                  ? SwitchItem(
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
        ],
      ),
    );
  }
}
