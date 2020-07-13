import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RctButton extends StatelessWidget {
  final VoidCallback onTap;
  final double buttonWidth;
  final Color buttonColor;
  final String buttonText;
  final Color textColor;
  final double textSize;
  final FaIcon icon;

  const RctButton({
    this.onTap,
    @required this.buttonWidth,
    @required this.buttonColor,
    @required this.buttonText,
    @required this.textColor,
    @required this.textSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: buttonWidth,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: this.buttonColor,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Row(
            mainAxisAlignment: icon == null
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: <Widget>[
              icon == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: icon,
                    ),
              Text(
                this.buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w500,
                  color: this.buttonColor == Colors.black
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
