import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';

class BottomNav extends StatelessWidget {
  final Function onTap;
  final bool show;
  final int index;

  const BottomNav({this.onTap, this.show, this.index});

  navButton(BuildContext context, int index, IconData iconData) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (show) {
          onTap(index);
        }
      },
      child: Container(
        width: 48,
        height: 48,
        child: Icon(
          iconData,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: AnimatedOpacity(
        duration: cardSlideDuration,
        curve: cardSlideCurve,
        opacity: show ? 1 : 0,
        child: Stack(
          children: [
            SizedBox.expand(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  navButton(context, 0, FeatherIcons.clock),
                  navButton(context, 1, FeatherIcons.list),
                  navButton(context, 2, FeatherIcons.percent),
                  navButton(context, 3, FeatherIcons.user),
                ],
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
                  ? (SizeConfig.safeBlockHorizontal * 100 - 4 * 48) / 5 + 12
                  : index == 1
                      ? (SizeConfig.safeBlockHorizontal * 100 - 4 * 48) /
                              5 *
                              2 +
                          60
                      : index == 2
                          ? (SizeConfig.safeBlockHorizontal * 100 - 4 * 48) /
                                  5 *
                                  3 +
                              108
                          : (SizeConfig.safeBlockHorizontal * 100 - 4 * 48) /
                                  5 *
                                  4 +
                              156,
              bottom: 20,
            ),
          ],
        ),
      ),
    );
  }
}
