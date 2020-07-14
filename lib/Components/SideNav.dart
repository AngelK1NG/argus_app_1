import 'package:flutter/material.dart';

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
      Navigator.pushNamed(context, newRoute);
      onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      curve: Curves.ease,
      top: -50,
      bottom: -50,
      left: active ? 0 : -280,
      width: 280,
      child: Container(
        padding: EdgeInsets.only(top: 170, bottom: 170, left: 32),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              spreadRadius: -5,
              blurRadius: 15,
            )
          ],
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                goToRoute(context, '/home');
              },
              child: Text("Focus",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                  )),
            ),
            FlatButton(
              onPressed: () {
                goToRoute(context, '/tasks');
              },
              child: Text("All Tasks",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                  )),
            ),
            FlatButton(
              onPressed: () {
                goToRoute(context, '/statistics');
              },
              child: Text("Statistics",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                  )),
            ),
            FlatButton(
              onPressed: () {
                goToRoute(context, '/settings');
              },
              child: Text("Settings",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
