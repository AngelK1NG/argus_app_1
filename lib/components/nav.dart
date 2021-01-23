import 'package:flutter/material.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/constants.dart';

class Nav extends StatelessWidget {
  final String title;
  final Color color;
  final IconData leftIconData;
  final VoidCallback leftOnTap;
  final IconData rightIconData;
  final VoidCallback rightOnTap;

  const Nav({
    @required this.title,
    @required this.color,
    this.leftIconData,
    this.leftOnTap,
    this.rightIconData,
    this.rightOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: SizeProvider.safeWidth,
      child: Stack(children: [
        Center(
          child: Text(
            title,
            style: this.color == white
                ? TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: white,
                  )
                : TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: black,
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
                      color: this.color,
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
                      color: this.color,
                    ),
                  ),
                ),
              ),
      ]),
    );
  }
}
