import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vivi/constants.dart';

class Button extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final Row row;
  final Color color;

  const Button({
    this.onTap,
    @required this.width,
    @required this.row,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: buttonDuration,
        curve: buttonCurve,
        width: width,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: Center(
          child: row,
        ),
      ),
    );
  }
}
