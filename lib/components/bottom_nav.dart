import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size_config.dart';

class BottomNav extends StatelessWidget {
  final Function onTap;
  final bool show;
  final int index;

  const BottomNav({this.onTap, this.show, this.index});

  Widget navButton(
    context, {
    @required int index,
    @required IconData iconData,
  }) {
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
                  navButton(context, index: 0, iconData: FeatherIcons.clock),
                  navButton(context, index: 1, iconData: FeatherIcons.list),
                  navButton(context, index: 2, iconData: FeatherIcons.percent),
                  navButton(context, index: 3, iconData: FeatherIcons.user),
                ],
              ),
            ),
            AnimatedPositioned(
              child: Container(
                width: 24,
                height: 2,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(1),
                  ),
                ),
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
