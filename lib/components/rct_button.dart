import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:Focal/constants.dart';

class RctButton extends StatelessWidget {
  final VoidCallback onTap;
  final double buttonWidth;
  final bool colored;
  final String buttonText;
  final double textSize;
  final FaIcon icon;

  const RctButton({
    this.onTap,
    @required this.buttonWidth,
    @required this.colored,
    @required this.buttonText,
    @required this.textSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: buttonWidth,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: colored 
            ? LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).accentColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
            : LinearGradient(
              colors: [jetBlack],
            )
          ,
          borderRadius: BorderRadius.all(Radius.circular(40)),
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

