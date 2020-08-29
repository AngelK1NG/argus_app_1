import 'package:flutter/material.dart';

class WrapperWidget extends StatefulWidget {
  final Widget child;

  const WrapperWidget({
    this.child,
  });

  @override
  _WrapperWidgetState createState() => _WrapperWidgetState();
}

class _WrapperWidgetState extends State<WrapperWidget> {

  @override
  void initState() {
    super.initState();
  }

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
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
