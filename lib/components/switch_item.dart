import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Focal/utils/size.dart';

class SwitchItem extends StatelessWidget {
  final String title;
  final bool toggle;
  final Function onChanged;
  SwitchItem({this.title, this.toggle, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: SizeProvider.safeWidth - 135,
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
        Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Divider(
            height: 0,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
