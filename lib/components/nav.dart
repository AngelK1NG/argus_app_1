import 'package:flutter/material.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/constants.dart';

class Nav extends StatelessWidget {
  final String title;
  final IconData leftIconData;
  final VoidCallback leftOnTap;
  final IconData rightIconData;
  final VoidCallback rightOnTap;
  final bool hideDivider;

  const Nav({
    @required this.title,
    this.leftIconData,
    this.leftOnTap,
    this.rightIconData,
    this.rightOnTap,
    this.hideDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: SizeProvider.safeWidth,
      child: Stack(
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? black
                    : white,
              ),
            ),
          ),
          this.leftIconData == null
              ? Container()
              : Positioned(
                  left: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: this.leftOnTap,
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.transparent,
                      child: Icon(
                        this.leftIconData,
                        size: 20,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? black
                            : white,
                      ),
                    ),
                  ),
                ),
          this.rightIconData == null
              ? Container()
              : Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: this.rightOnTap,
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.transparent,
                      child: Icon(
                        this.rightIconData,
                        size: 20,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? black
                            : white,
                      ),
                    ),
                  ),
                ),
          this.hideDivider == true
              ? Container()
              : Positioned(
                  left: 15,
                  right: 15,
                  bottom: 0,
                  child: Divider(
                    height: 0,
                    thickness: 1,
                  ),
                ),
        ],
      ),
    );
  }
}
