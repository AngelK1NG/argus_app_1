import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SqrButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color buttonColor;
  final FaIcon icon; 

  const SqrButton({this.onTap, @required this.buttonColor, @required this.icon});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: icon,
      ),
    );
  }
}