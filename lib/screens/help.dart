import 'package:Focal/constants.dart';
import 'package:Focal/utils/size.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

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
        children: [
          Positioned(
            right: 25,
            left: 25,
            top: 17,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    height: 40,
                    width: SizeConfig.safeWidth,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => widget.goToPage(2),
                            child: Container(
                              width: 40,
                              height: 40,
                              color: Colors.white,
                              child: Icon(
                                FeatherIcons.chevronLeft,
                                size: 20,
                                color: black,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Help',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
