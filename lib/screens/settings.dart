import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:vivi/components/menu_item.dart';
import 'package:vivi/components/header.dart';
import 'package:vivi/components/footer.dart';
import 'package:vivi/utils/auth.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/constants.dart';

class SettingsPage extends StatelessWidget {
  final Function goToPage;

  SettingsPage({
    @required this.goToPage,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var email = Provider.of<UserStatus>(context).email;
    return WillPopScope(
      onWillPop: () => this.goToPage(0),
      child: Center(
        child: Container(
          height: SizeProvider.safeHeight - 30,
          width: SizeProvider.safeWidth - 30,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: -5,
                color: Theme.of(context).shadowColor,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Header(
                    title: 'Settings',
                  ),
                  MenuItem(
                    iconData: FeatherIcons.logOut,
                    iconColor: Theme.of(context).accentColor,
                    check: false,
                    text: 'Sign Out',
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      FirebaseAuth.instance.signOut();
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
              Footer(
                blackString: 'Done',
                blackOnTap: () {
                  this.goToPage(0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
