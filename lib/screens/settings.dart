import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/settings_item.dart';
import 'package:Focal/components/nav_button.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:Focal/utils/user.dart';

class SettingsPage extends StatefulWidget {
  final Function goToPage;
  final Function setLoading;

  SettingsPage({
    @required this.goToPage,
    @required this.setLoading,
    Key key,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = true;
  String _email = '';

  void openFeedbackForm() async {
    const URL = 'https://forms.gle/bjAmY4r6TGTC9ybe7';
    if (await canLaunch(URL)) {
      await launch(URL);
    } else {
      print('Couldn\'t find url');
    }
  }

  @override
  void initState() {
    super.initState();
    _email = Provider.of<User>(context, listen: false).user.email;
    Future.delayed(Duration.zero, () {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.goToPage(0),
      child: Stack(children: <Widget>[
        Container(
          alignment: Alignment.center,
          height: 50,
          child: Text(
            'Settings',
            style: whiteHeaderTextStyle,
          ),
        ),
        Positioned(
          left: 5,
          top: 0,
          child: NavButton(
            onTap: () {
              widget.goToPage(0);
            },
            iconData: FeatherIcons.chevronLeft,
            color: white,
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: AnimatedOpacity(
            opacity: _loading ? 0 : 1,
            duration: cardDuration,
            curve: cardCurve,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SettingsItem(
                  iconData: FeatherIcons.settings,
                  text: 'General',
                  onTap: () => widget.goToPage(4),
                ),
                SettingsItem(
                  iconData: FeatherIcons.archive,
                  text: 'Feedback',
                  onTap: () => openFeedbackForm(),
                ),
                // SettingsTile(
                //   iconData: FeatherIcons.helpCircle,
                //   text: 'Help',
                //   onTap: () => widget.goToPage(5),
                // ),
                SettingsItem(
                  iconData: FeatherIcons.info,
                  text: 'About',
                  onTap: () => widget.goToPage(6),
                ),
                SettingsItem(
                  iconData: FeatherIcons.logOut,
                  text: 'Sign Out',
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    auth.signOut();
                    AnalyticsProvider().logSignOut();
                  },
                ),
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    'Signed in as: ' + _email,
                    style: TextStyle(
                      color: hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
