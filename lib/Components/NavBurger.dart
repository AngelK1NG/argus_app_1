import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavBurger extends StatelessWidget {
  final VoidCallback onTap;
  final FaIcon icon;

  const NavBurger({this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 50),
      child: IconButton(
        onPressed: onTap,
        icon: icon,
      ),
    );
  }
}