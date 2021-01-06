import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/constants.dart';

class Task extends StatelessWidget {
  final String name;
  final bool completed;
  final String date;
  final bool paused;
  final int seconds;
  final String id;
  final Function onDismissed;
  final Function onTap;

  const Task({
    @required this.id,
    @required this.name,
    @required this.date,
    @required this.completed,
    @required this.paused,
    @required this.seconds,
    this.onDismissed,
    this.onTap,
    Key key,
  }) : super(key: key);

  factory Task.fromFirestore(DocumentSnapshot doc, bool completed) {
    Map data = doc.data;
    return Task(
      id: doc.documentID,
      name: data['name'] ?? '',
      date: data['date'] ?? '',
      completed: completed,
      paused: data['paused'] ?? false,
      seconds: data['seconds'] ?? 0,
    );
  }

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
                            color: this.paused
                                ? Theme.of(context).primaryColor
                                : black,
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
                                color: black,
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
