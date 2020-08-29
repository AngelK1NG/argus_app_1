import 'package:flutter/material.dart';

class WrapperWidget extends StatelessWidget {
  final Widget child;

  const WrapperWidget({
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowGlow();
          return null;
        },
        child: SizedBox.expand(
          child: SafeArea(
            child: child,
          ),
        ),
      ),
    );
  }
}
