import 'package:flutter/material.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/constants.dart';

class Footer extends StatelessWidget {
  final String redString;
  final VoidCallback redOnTap;
  final String blackString;
  final VoidCallback blackOnTap;

  const Footer({
    this.redString,
    this.redOnTap,
    @required this.blackString,
    @required this.blackOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: SizeProvider.safeWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          this.redString == null
              ? Container()
              : GestureDetector(
                  onTap: this.redOnTap,
                  child: Container(
                    width: (SizeProvider.safeWidth - 30) / 2,
                    height: 50,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      this.redString,
                      style: TextStyle(
                        fontSize: 16,
                        color: red,
                      ),
                    ),
                  ),
                ),
          GestureDetector(
            onTap: this.blackOnTap,
            child: Container(
              width: (SizeProvider.safeWidth - 30) / 2,
              height: 50,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Text(
                this.blackString,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          //       ),
        ],
      ),
    );
  }
}
