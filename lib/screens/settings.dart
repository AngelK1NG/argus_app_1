import 'package:flutter/material.dart';
import 'package:Focal/constants.dart';
import '../components/wrapper.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _email = "houjun@shabangshit.cf";

  @override
  Widget build(BuildContext context) {
    return WrapperWidget(
      nav: true,
      child: Stack(
        children: <Widget>[
          Positioned (
            right: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 38, top: 30,),
              child: Text("Settings", style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),),
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            top: 100,
            child: Container(),
          ),
          Positioned (
            right: 0,
            left: 0,
            bottom: 120,
            child: Text("You are signed in with Google as " + _email, textAlign: TextAlign.center, style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).hintColor,
            )),
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30, right: 38, left: 38,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      auth.signOut();
                    },
                    child: Text("Sign out", style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    )),
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Text("Terms of Service", style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w400,
                    )),
                  ),
                ],
              )
            )
          )
        ]
      ),
    );
  }
}