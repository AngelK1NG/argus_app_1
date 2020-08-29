import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';

class BottomNav extends StatelessWidget {
  final Function onTap;
  final bool show;
  final int index;

  const BottomNav({this.onTap, this.show, this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: show ? 80 : 0,
      child: show
        ? Stack(
          children: [
            SizedBox.expand(
              child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      FeatherIcons.clock,
                    ),
                    title: Text('Home'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      FeatherIcons.list,
                    ),
                    title: Text('Tasks'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      FeatherIcons.percent,
                    ),
                    title: Text('Statistics'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      FeatherIcons.user,
                    ),
                    title: Text('Profile'),
                  ),
                ],
                selectedIconTheme: IconThemeData(
                  color: Theme.of(context).primaryColor,
                ),
                unselectedIconTheme: IconThemeData(
                  color: Theme.of(context).primaryColor,
                ),
                iconSize: 24,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.fixed,
                currentIndex: index,
                onTap: onTap,
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            AnimatedPositioned(
              child: Container(
                width: 24,
                height: 2,
                color: Theme.of(context).primaryColor,
              ),
              duration: loadingDuration,
              curve: loadingCurve,
              left: index == 0
                ? SizeConfig.safeBlockHorizontal * 9.5
                : index == 1
                  ? SizeConfig.safeBlockHorizontal * 34.5
                  : index == 2
                    ? SizeConfig.safeBlockHorizontal * 65.5 - 24
                    : SizeConfig.safeBlockHorizontal * 90.5 - 24
              ,
              bottom: 20,
            ),
          ],
        )
        : Container(),
    );
  }
}