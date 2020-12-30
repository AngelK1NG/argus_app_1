import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

class SettingsItem extends StatelessWidget {
  final IconData iconData;
  final String text;
  final String secondaryText;
  final VoidCallback onTap;

  SettingsItem({
    this.iconData,
    @required this.text,
    this.secondaryText,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: iconData == null ? 0 : 0,
          right: 0,
          child: Container(height: 1, color: Theme.of(context).dividerColor),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    iconData != null
                        ? Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Icon(iconData,
                                size: 20,
                                color: Theme.of(context).primaryColor),
                          )
                        : Container(),
                    SizedBox(
                      width: 200,
                      child: Text(
                        text,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    secondaryText != null
                        ? Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: Text(
                              secondaryText,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          )
                        : Container(),
                    Icon(FeatherIcons.chevronRight,
                        size: 20, color: Theme.of(context).hintColor),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
