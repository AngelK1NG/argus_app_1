import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Focal/utils/size_config.dart';

class SettingsSwitchItem extends StatelessWidget {
  final String title;
  final bool toggle;
  final Function onChanged;
  SettingsSwitchItem({this.title, this.toggle, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(height: 1, color: Theme.of(context).dividerColor),
        ),
        Container(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: SizeConfig.safeBlockHorizontal * 100 - 135,
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
        ),
      ],
    );
  }
}
