import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final bool toggle;
  final Function onChanged;
  SettingsTile({this.title, this.toggle, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ),
          CupertinoSwitch(
            activeColor: Theme.of(context).accentColor,
            trackColor: Colors.grey,
            value: toggle,
            onChanged: (value) {
              HapticFeedback.heavyImpact();
              onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
