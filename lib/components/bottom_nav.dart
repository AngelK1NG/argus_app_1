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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      FeatherIcons.clock,
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => onTap(0),
                  ),
                  IconButton(
                    icon: Icon(
                      FeatherIcons.list,
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => onTap(1),
                  ),
                  IconButton(
                    icon: Icon(
                      FeatherIcons.percent,
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => onTap(2),
                  ),
                  IconButton(
                    icon: Icon(
                      FeatherIcons.user,
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => onTap(3),
                  ),
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
                  ? (SizeConfig.safeBlockHorizontal * 100 - 4 * 48) / 5 * 2 + 60
                  : index == 2
                    ? (SizeConfig.safeBlockHorizontal * 100 - 4 * 48) / 5 * 3 + 108
                    : (SizeConfig.safeBlockHorizontal * 100 - 4 * 48) / 5 * 4 + 156
              ,
              bottom: 20,
            ),
          ],
        )
        : Container(),
    );
  }
}