import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

class MenuItem extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final bool check;
  final String text;
  final String secondaryText;
  final VoidCallback onTap;

  MenuItem({
    @required this.iconData,
    @required this.iconColor,
    @required this.check,
    @required this.text,
    this.secondaryText,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 50,
            padding: EdgeInsets.only(left: 15, right: 15),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    iconData != null
                        ? Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Icon(
                              iconData,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
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
                    check
                        ? Icon(
                            FeatherIcons.check,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          )
                        : Icon(
                            FeatherIcons.chevronRight,
                            size: 20,
                            color: Theme.of(context).hintColor,
                          ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
