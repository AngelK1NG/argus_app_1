import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/constants.dart';

// ignore: must_be_immutable
class TaskItem extends StatelessWidget {
  String name;
  bool completed;
  bool paused;
  int seconds;
  String id;
  Function onDismissed;
  Function onTap;

  TaskItem({
    @required this.name,
    @required this.completed,
    this.paused,
    this.seconds,
    this.id,
    this.onDismissed,
    this.onTap,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0,
          left: 20,
          right: 20,
          child: Divider(
            height: 0,
            thickness: 1,
          ),
        ),
        Dismissible(
          background: Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.only(left: 20),
            alignment: AlignmentDirectional.centerStart,
            child: Icon(
              FeatherIcons.sunrise,
              color: Colors.white,
              size: 20,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            padding: EdgeInsets.only(right: 20),
            alignment: AlignmentDirectional.centerEnd,
            child: Icon(
              FeatherIcons.trash,
              color: Colors.white,
              size: 20,
            ),
          ),
          key: UniqueKey(),
          direction: this.completed
              ? DismissDirection.endToStart
              : DismissDirection.horizontal,
          onDismissed: this.onDismissed,
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.deferToChild,
            child: Container(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 15),
                    child: this.completed
                        ? Icon(
                            FeatherIcons.checkCircle,
                            size: 20,
                            color: Theme.of(context).hintColor,
                          )
                        : Icon(
                            FeatherIcons.circle,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                  ),
                  SizedBox(
                    width: SizeConfig.safeWidth - 75,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        this.name,
                        style: this.completed
                            ? TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).hintColor,
                              )
                            : TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: this.paused != null && this.paused
                                    ? Theme.of(context).primaryColor
                                    : black,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              height: 50,
              width: SizeConfig.safeWidth,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }
}
