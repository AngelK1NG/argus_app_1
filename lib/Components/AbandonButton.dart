import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AbandonButton extends StatelessWidget {
  final VoidCallback onTap;

  const AbandonButton({this.onTap});

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
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: FaIcon(FontAwesomeIcons.running, color: Colors.white, size: 32,),
      ),
    );
  }
}