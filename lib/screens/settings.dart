import 'package:Focal/utils/local_notifications.dart';
import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import 'package:provider/provider.dart';
import '../components/wrapper.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1), () {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String _email = Provider.of<User>(context, listen: false).user.email;
    return WrapperWidget(
      loading: _loading,
      nav: true,
      cardPosition: MediaQuery.of(context).size.height / 2 - 240,
      backgroundColor: Theme.of(context).primaryColor,
      child: Stack(children: <Widget>[
        Positioned(
          right: 0,
          top: 0,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 38,
              top: 30,
            ),
            child: Text(
              "Settings",
              style: headerTextStyle,
            ),
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          top: 100,
          child: Container(),
        ),
        Positioned(
          right: 30,
          left: 30,
          bottom: 120,
          child: Text("You are signed in as " + _email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).hintColor,
              )),
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
                      child: Text("Terms of Service",
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w400,
                          )),
                    ),
                  ],
                )))
      ]),
    );
  }
}
