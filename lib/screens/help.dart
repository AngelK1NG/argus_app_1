import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

class HelpPage extends StatefulWidget {
  final Function goToPage;

  HelpPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(cardSlideDuration, () {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.goToPage(3),
      child: Stack(children: <Widget>[
        Positioned(
          left: 25,
          top: SizeConfig.safeBlockVertical * 5,
          child: Text(
            'Settings',
            style: headerTextStyle,
          ),
        ),
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: loadingDuration,
          curve: loadingCurve,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 25,
                left: 25,
                top: SizeConfig.safeBlockVertical * 15 + 17,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => widget.goToPage(3),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.white,
                                  child: Icon(
                                    FeatherIcons.chevronLeft,
                                    size: 20,
                                    color: jetBlack,
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
        ),
      ]),
    );
  }
}
