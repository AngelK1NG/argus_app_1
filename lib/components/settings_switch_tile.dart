import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final bool toggle;
  final Function onChanged;
  SettingsSwitchTile({this.title, this.toggle, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width - 135,
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ),
          CupertinoSwitch(
            activeColor: Theme.of(context).primaryColor,
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
