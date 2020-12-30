import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData iconData;
  final Color color;

  const NavButton({
    this.onTap,
    @required this.iconData,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        color: Colors.transparent,
        child: Icon(
          iconData,
          size: 20,
          color: color,
        ),
      ),
    );
  }
}
