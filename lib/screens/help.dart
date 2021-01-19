import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  final Function goToPage;

  HelpPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.goToPage(2),
      child: Stack(
        children: [],
      ),
    );
  }
}
