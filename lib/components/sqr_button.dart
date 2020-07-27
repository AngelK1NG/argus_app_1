import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SqrButton extends StatelessWidget {
  final VoidCallback onTap;
  final dynamic icon; 

  const SqrButton({this.onTap, @required this.icon});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(33)),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: 66,
        height: 66,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.all(Radius.circular(33)),
        ),
        child: icon,
      ),
    );
  }
}