import 'package:flutter/material.dart';
import 'package:Focal/utils/size.dart';

class OverlayHeader extends StatelessWidget {
  final String title;
  final Text leftText;
  final VoidCallback leftOnTap;
  final Text rightText;
  final VoidCallback rightOnTap;

  const OverlayHeader({
    @required this.title,
    this.leftText,
    this.leftOnTap,
    this.rightText,
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: GestureDetector(
            onTap: this.leftOnTap,
            child: Container(
              height: 50,
              padding: EdgeInsets.only(left: 15, right: 15),
              alignment: Alignment.center,
              color: Colors.transparent,
              child: leftText,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: this.rightOnTap,
            child: Container(
              height: 50,
              padding: EdgeInsets.only(left: 15, right: 15),
              alignment: Alignment.center,
              color: Colors.transparent,
              child: rightText,
            ),
          ),
        ),
      ]),
    );
  }
}
