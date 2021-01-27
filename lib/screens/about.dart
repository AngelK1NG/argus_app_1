import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:launch_review/launch_review.dart';
import 'package:Focal/components/nav.dart';

class AboutPage extends StatefulWidget {
  final Function goToPage;

  AboutPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  void openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Couldn\'t find url');
    }
  }

  Widget textButton({@required VoidCallback onTap, @required String text}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
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
      setState(() => _version =
          'Version ${packageInfo.version} (${packageInfo.buildNumber})');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.goToPage(2),
      child: Stack(
        children: [
          Nav(
            title: 'About',
            leftIconData: FeatherIcons.chevronLeft,
            leftOnTap: () {
              widget.goToPage(2);
            },
          ),
          Positioned(
            right: 0,
            left: 0,
            top: 100,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Image(
                    image: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? AssetImage('assets/images/Logo Large Light.png')
                        : AssetImage('assets/images/Logo Large Dark.png'),
                    width: 150,
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                    colorBlendMode: BlendMode.modulate,
                  ),
                ),
                Text(_version),
              ],
            ),
          ),
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              textButton(
                onTap: () {
                  LaunchReview.launch(
                      androidAppId: 'technology.focal.focal',
                      iOSAppId: '1526256598');
                },
                text: 'Rate Focal',
              ),
              textButton(
                onTap: () {
                  openUrl('https://getfocal.app/terms');
                },
                text: 'Terms and Conditions',
              ),
              textButton(
                onTap: () {
                  openUrl('https://getfocal.app/privacy');
                },
                text: 'Privacy Policy',
              ),
              textButton(
                onTap: () {
                  openUrl('https://getfocal.app');
                },
                text: 'Website',
              ),
            ],
          )),
          Positioned(
            left: 0,
            right: 0,
            bottom: 15,
            child: Center(
              child: Text(
                '© 2020 Focal LLC',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
