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
        width: 60,
        height: 60,
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
        duration: cardDuration,
        curve: cardCurve,
        opacity: show ? 1 : 0,
        child: Stack(
          children: [
            Positioned(
              left: 25,
              right: 25,
              top: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              duration: cardDuration,
              curve: cardCurve,
              left: index == 0
                  ? 43
                  : index == 1
                      ? (SizeConfig.safeBlockHorizontal * 100 - 290) / 3 + 103
                      : index == 2
                          ? (SizeConfig.safeBlockHorizontal * 100 - 290) /
                                  3 *
                                  2 +
                              163
                          : (SizeConfig.safeBlockHorizontal * 100 - 290) + 223,
              bottom: 20,
            ),
          ],
        ),
      ),
    );
  }
}
