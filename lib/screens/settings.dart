import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/settings_item.dart';
import 'package:Focal/components/nav_button.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:Focal/utils/auth.dart';

class SettingsPage extends StatelessWidget {
  final Function goToPage;

  SettingsPage({
    @required this.goToPage,
    Key key,
  }) : super(key: key);

  void openFeedbackForm() async {
    const URL = 'https://forms.gle/bjAmY4r6TGTC9ybe7';
    if (await canLaunch(URL)) {
      await launch(URL);
    } else {
      print('Couldn\'t find url');
    }
  }

  @override
  Widget build(BuildContext context) {
    var email = Provider.of<UserStatus>(context).email;
    return WillPopScope(
      onWillPop: () => this.goToPage(0),
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
              this.goToPage(0);
            },
            iconData: FeatherIcons.chevronLeft,
            color: white,
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SettingsItem(
                iconData: FeatherIcons.settings,
                text: 'General',
                onTap: () => this.goToPage(4),
              ),
              SettingsItem(
                iconData: FeatherIcons.archive,
                text: 'Feedback',
                onTap: () => openFeedbackForm(),
              ),
              // SettingsTile(
              //   iconData: FeatherIcons.helpCircle,
              //   text: 'Help',
              //   onTap: () => this.goToPage(5),
              // ),
              SettingsItem(
                iconData: FeatherIcons.info,
                text: 'About',
                onTap: () => this.goToPage(6),
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
                  'Signed in as: ' + email,
                  style: TextStyle(
                    color: hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
