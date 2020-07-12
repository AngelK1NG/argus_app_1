import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavBurger extends StatelessWidget {
  final VoidCallback onTap;
  final bool active;

  const NavBurger({this.onTap, this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102,
      height: 102,
      padding: EdgeInsets.only(top: 36),
      child: IconButton(
        onPressed: onTap,
        icon: active ? FaIcon(FontAwesomeIcons.times, size: 32,) : FaIcon(FontAwesomeIcons.bars, size: 32,),
      ),
    );
  }
}