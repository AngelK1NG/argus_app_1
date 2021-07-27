import 'package:flutter/material.dart';
import 'package:vivi/utils/size.dart';

class Header extends StatelessWidget {
  final String title;

  const Header({
    @required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: SizeProvider.safeWidth,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
