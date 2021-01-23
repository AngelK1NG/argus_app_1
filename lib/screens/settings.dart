import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Focal/components/menu_item.dart';
import 'package:Focal/components/nav.dart';
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
      child: Column(
        children: [
          Nav(
            title: 'Settings',
            leftIconData: FeatherIcons.chevronLeft,
            leftOnTap: () {
              this.goToPage(0);
            },
          ),
          MenuItem(
            iconData: FeatherIcons.settings,
            iconColor: Theme.of(context).primaryColor,
            check: false,
            text: 'General',
            onTap: () => this.goToPage(4),
          ),
          MenuItem(
            iconData: FeatherIcons.archive,
            iconColor: Theme.of(context).primaryColor,
            check: false,
            text: 'Feedback',
            onTap: () => openFeedbackForm(),
          ),
          // MenuItem(
          //   iconData: FeatherIcons.helpCircle,
          //   iconColor: Theme.of(context).primaryColor,
          //   check: false,
          //   text: 'Help',
          //   onTap: () => this.goToPage(5),
          // ),
          MenuItem(
            iconData: FeatherIcons.info,
            iconColor: Theme.of(context).primaryColor,
            check: false,
            text: 'About',
            onTap: () => this.goToPage(6),
          ),
          MenuItem(
            iconData: FeatherIcons.logOut,
            iconColor: Theme.of(context).primaryColor,
            check: false,
            text: 'Sign Out',
            onTap: () {
              HapticFeedback.heavyImpact();
              FirebaseAuth.instance.signOut();
              AnalyticsProvider().logSignOut();
            },
          ),
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
              'Signed in as: ' + email,
              style: TextStyle(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
