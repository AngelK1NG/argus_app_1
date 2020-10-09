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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Theme.of(context).accentColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: icon,
      ),
    );
  }
}