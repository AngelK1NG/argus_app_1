import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsTile extends StatefulWidget {
  final String title;
  final bool toggle;
  final Function onChanged;
  SettingsTile({this.title, this.toggle, this.onChanged});

  @override
  _SettingsTileState createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(fontSize: 17),
          ),
          Container(
            width: 100.0,
            child: CupertinoSwitch(
              activeColor: Colors.purple,
              trackColor: Colors.grey,
              value: widget.toggle,
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
