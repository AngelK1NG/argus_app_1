import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:launch_review/launch_review.dart';

class AboutPage extends StatefulWidget {
  final Function goToPage;

  AboutPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _loading = true;
  String _version = '';

  void openURL(String URL) async {
    if (await canLaunch(URL)) {
      await launch(URL);
    } else {
      print('Couldn\'t find url');
    }
  }

  textButton(VoidCallback onTap, String text) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: 150,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      _version = 'Version ${packageInfo.version} (${packageInfo.buildNumber})';
      Future.delayed(cardSlideDuration, () {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      });
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
                                'About',
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
                    Image(
                      image:
                          AssetImage('assets/images/logo/Focal Logo_Full.png'),
                      width: 200,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 25),
                      child: Text(
                        _version,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    textButton(
                      () {
                        LaunchReview.launch(androidAppId: 'technology.focal.focal', iOSAppId: '1526256598');
                      },
                      'Rate Focal',
                    ),
                    textButton(
                      () {
                        openURL(
                            'https://docs.google.com/document/d/1h0fBpGKMKHna0MSA8NTt0FXAdc551ALwSkVWJkh0mbY/edit?usp=sharing');
                      },
                      'Terms & Conditions',
                    ),
                    textButton(
                      () {
                        openURL(
                            'https://docs.google.com/document/d/1eIL0fXCFXXoiIfU59qPXqnQxhKp-8VG2XTvh63O0d-o/edit?usp=sharing');
                      },
                      'Privacy Policy',
                    ),
                    textButton(
                      () {
                        openURL('https://focal.technology');
                      },
                      'Website',
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 25,
                right: 25,
                bottom: 80,
                child: Center(
                  child: Text(
                    '© 2020 Focal LLC',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
