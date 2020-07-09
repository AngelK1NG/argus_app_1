import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color buttonColor;
  final String buttonText;

  const HomeButton({this.onTap, this.buttonColor, this.buttonText});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: 240,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: this.buttonColor,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Text(this.buttonText, textAlign: TextAlign.center, style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: this.buttonColor == Colors.black ? Colors.white : Colors.black,
        ),),
      ),
    );
  }
}