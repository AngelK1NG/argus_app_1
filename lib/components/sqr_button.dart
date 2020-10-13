import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Focal/constants.dart';

class SqrButton extends StatelessWidget {
  final VoidCallback onTap;
  final dynamic icon;
  final LinearGradient gradient;
  final bool vibrate;

  const SqrButton({
    @required this.onTap,
    @required this.icon,
    @required this.gradient,
    @required this.vibrate,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        if (vibrate) {
          HapticFeedback.heavyImpact();
        }
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.all(0.0),
      child: AnimatedContainer(
        duration: buttonDuration,
        curve: buttonCurve,
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: icon,
      ),
    );
  }
}