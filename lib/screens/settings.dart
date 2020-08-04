import 'package:Focal/components/settings_tile.dart';
import 'package:Focal/utils/local_notifications.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/wrapper.dart';
import 'dart:io' show Platform;

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = true;
  bool _notificationsOn = true;
  bool _dndOn = true;
  // bool _soundOn = true;

  void getSettings() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      setState(() {
        _notificationsOn = prefs.getBool('notifications on') == null
            ? true
            : prefs.getBool('notifications on');
        _dndOn = prefs.getBool('do not disturb on') == null
            ? true
            : prefs.getBool('do not disturb on');
        _notificationsOn = prefs.getBool('notifications on') == null
            ? true
            : prefs.getBool('notifications on');
        // _soundOn = prefs.getBool('sound on') == null
        //     ? true
        //     : prefs.getBool('sound on');
        _loading = false;
      });
    });
  }

  void setValue(String key, bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, val);
    print('$key is set to ${prefs.get}');
  }

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    String _email = Provider.of<User>(context, listen: false).user.email;
    return WrapperWidget(
      loading: _loading,
      nav: true,
      cardPosition: SizeConfig.safeBlockVertical * 15,
      backgroundColor: Theme.of(context).primaryColor,
      staticChild: Stack(children: <Widget>[
        Positioned(
          right: 0,
          top: 0,
          child: Padding(
            padding: EdgeInsets.only(
              right: 40,
              top: SizeConfig.safeBlockVertical * 5,
            ),
            child: Text(
              "Settings",
              style: headerTextStyle,
            ),
          ),
        ),
      ]),
      dynamicChild: Stack(children: <Widget>[
        Positioned(
          right: 40,
          left: 40,
          top: SizeConfig.safeBlockVertical * 15 + 40,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 25),
                  child: Text(
                    'Notifications',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ),
                SettingsTile(
                  title: 'Notify upon exiting app when Focused',
                  toggle: _notificationsOn,
                  onChanged: (value) {
                    setState(() {
                      _notificationsOn = value;
                    });
                    LocalNotificationHelper.notificationsOn = value;
                    setValue('notifications on', value);
                  },
                ),
                Platform.isAndroid
                    ? SettingsTile(
                        title: 'Turn on Do Not Disturb when Focused',
                        toggle: _dndOn,
                        onChanged: (value) {
                          setState(() {
                            _dndOn = value;
                          });
                          LocalNotificationHelper.dndOn = value;
                          setValue('do not disturb on', value);
                        })
                    : Container(),
                // Padding(
                //   padding: EdgeInsets.only(top: 50, bottom: 25),
                //   child: Text(
                //     'Sounds',
                //     style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                //   ),
                // ),
                // SettingsTile(
                //   title: 'Notification sounds',
                //   toggle: _soundOn,
                //   onChanged: (value) {
                //     setState(() {
                //       _soundOn = value;
                //     });
                //     setValue('sound on', value);
                //   },
                // ),
              ],
            ),
          ),
        ),
        _email == null
            ? Container()
            : Positioned(
                right: 40,
                left: 40,
                bottom: 120,
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
          right: 0,
          left: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 30,
              right: 38,
              left: 38,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    LocalNotificationHelper.userLoggedIn = false;
                    auth.signOut();
                  },
                  child: Text("Sign out",
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                      )),
                ),
                FlatButton(
                  onPressed: () {},
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
        ),
      ]),
    );
  }
}
