import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Focal/constants.dart';

class Button extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final Row row;
  final LinearGradient gradient;
  final bool vibrate;

  const Button({
    this.onTap,
    @required this.width,
    @required this.row,
    @required this.gradient,
    @required this.vibrate,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (vibrate) {
          HapticFeedback.heavyImpact();
        }
        onTap();
      },
      child: AnimatedContainer(
        duration: buttonDuration,
        curve: buttonCurve,
        width: width,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: Center(
          child: row,
        ),
      ),
    );
  }
}
