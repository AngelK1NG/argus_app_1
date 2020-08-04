import 'package:Focal/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SideNav extends StatelessWidget {
  final VoidCallback onTap;
  final active;

  const SideNav({this.onTap, this.active});

  void goToRoute(BuildContext context, String newRoute) {
    bool isNewRouteSameAsCurrent = false;

    Navigator.popUntil(context, (route) {
      if (route.settings.name == newRoute) {
        isNewRouteSameAsCurrent = true;
      }
      return true;
    });

    if (!isNewRouteSameAsCurrent) {
      if (newRoute == '/home') {
        Navigator.pushNamedAndRemoveUntil(
            context, newRoute, ModalRoute.withName('/login'));
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, newRoute, ModalRoute.withName('/home'));
      }
    }

    onTap();
  }

  openFeedbackForm() async {
    const feedbackURL = 'https://forms.gle/YKVpEAimFx3T6kn39';
    if (await canLaunch(feedbackURL)) {
      await launch(feedbackURL);
    } else {
      print('Couldn\'t find url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: navDuration,
      curve: navCurve,
      top: 0,
      bottom: 0,
      left: active ? 0 : -300,
      width: 280,
      child: Container(
        padding: EdgeInsets.only(top: 60, bottom: 60, left: 32),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              spreadRadius: -5,
              blurRadius: 15,
            )
          ],
          color: Colors.white,
        ),
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    goToRoute(context, '/home');
                  },
                  child: Text("Focus",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: jetBlack,
                      )),
                ),
                FlatButton(
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    goToRoute(context, '/tasks');
                  },
                  child: Text("All Tasks",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: jetBlack,
                      )),
                ),
                FlatButton(
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    goToRoute(context, '/statistics');
                  },
                  child: Text("Statistics",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: jetBlack,
                      )),
                ),
                FlatButton(
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    goToRoute(context, '/settings');
                  },
                  child: Text("Settings",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: jetBlack,
                      )),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: FlatButton(
                onPressed: () {
                  goToRoute(context, '/home');
                  Navigator.of(context).pushReplacementNamed('/onboarding');
                },
                child: Row(
                  children: <Widget>[
                    Text(
                      "Help",
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: FaIcon(
                        FontAwesomeIcons.questionCircle,
                        color: Theme.of(context).hintColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
