import 'package:Focal/constants.dart';
import 'package:Focal/components/settings_switch_tile.dart';
import 'package:Focal/components/settings_tile.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'dart:io' show Platform;

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
  int _dayStartHour = 0;
  int _dayStartMinute = 0;

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
      if (_prefs.getInt('dayStartHour') == null) {
        _dayStartHour = 0;
        _prefs.setInt('dayStartHour', 0);
      } else {
        _dayStartHour = _prefs.getInt('dayStartHour');
      }
      if (_prefs.getInt('dayStartMinute') == null) {
        _dayStartMinute = 0;
        _prefs.setInt('dayStartMinute', 0);
      } else {
        _dayStartMinute = _prefs.getInt('dayStartMinute');
      }
    });
    Future.delayed(cardSlideDuration, () {
      if (mounted) {
        setState(() {
          _loading = false;
        });
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
      onWillPop: () => widget.goToPage(3),
      child: Stack(children: <Widget>[
        Positioned(
          left: 25,
          top: SizeConfig.safeBlockVertical * 5,
          child: Text(
            'Settings',
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
                top: SizeConfig.safeBlockVertical * 15 + 17,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => widget.goToPage(3),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.white,
                                  child: Icon(
                                    FeatherIcons.chevronLeft,
                                    size: 20,
                                    color: jetBlack,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'General',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SettingsSwitchTile(
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
                        ? SettingsSwitchTile(
                            title: 'Turn on Do Not Disturb when Focused',
                            toggle: _focusDnd,
                            onChanged: (value) {
                              setState(() {
                                _focusDnd = value;
                              });
                              setBool('focusDnd', value);
                            })
                        : Container(),
                    Container(
                        alignment: Alignment.center,
                        height: 25,
                        child: Container(
                          height: 1,
                          color: Theme.of(context).dividerColor,
                        )),
                    SettingsTile(
                      text: 'Day start time',
                      chevron: true,
                      divider: false,
                      secondaryText: _dayStartHour == 0
                          ? '12:' +
                              _dayStartMinute.toString().padLeft(2, '0') +
                              ' AM'
                          : _dayStartHour == 12
                              ? '12:' +
                                  _dayStartMinute.toString().padLeft(2, '0') +
                                  ' PM'
                              : _dayStartHour < 12
                                  ? _dayStartHour.toString() +
                                      ':' +
                                      _dayStartMinute
                                          .toString()
                                          .padLeft(2, '0') +
                                      ' AM'
                                  : (_dayStartHour - 12).toString() +
                                      ':' +
                                      _dayStartMinute
                                          .toString()
                                          .padLeft(2, '0') +
                                      ' PM',
                      onTap: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: _dayStartHour,
                            minute: _dayStartMinute,
                          ),
                        ).then((time) {
                          if (time != null) {
                            setState(() {
                              _dayStartHour = time.hour;
                              _dayStartMinute = time.minute;
                              setInt('dayStartHour', time.hour);
                              setInt('dayStartMinute', time.minute);
                            });
                          }
                        });
                      },
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
