import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/constants.dart';

class Task extends StatelessWidget {
  final int index;
  final String name;
  final String date;
  final bool completed;
  final bool paused;
  final int seconds;
  final String id;
  final Function onDismissed;
  final Function onTap;

  const Task({
    @required this.index,
    @required this.name,
    @required this.date,
    @required this.completed,
    @required this.paused,
    @required this.seconds,
    this.id,
    this.onDismissed,
    this.onTap,
    Key key,
  }) : super(key: key);

  factory Task.fromFirestore(DocumentSnapshot doc, bool completed) {
    Map data = doc.data();
    return Task(
      id: doc.id,
      index: data['index'] ?? 0,
      name: data['name'] ?? '',
      date: data['date'] ?? '',
      completed: completed,
      paused: data['paused'] ?? false,
      seconds: data['seconds'] ?? 0,
    );
  }

  void updateDoc(UserStatus user, VoidCallback callback) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('uncompleted')
        .doc(this.id)
        .update({
      'index': this.index,
      'name': this.name,
      'date': this.date,
      'paused': this.paused,
      'seconds': this.seconds,
    }).then((_) {
      callback();
    });
  }

  void addDoc(UserStatus user) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('uncompleted')
        .add({
      'index': this.index,
      'name': this.name,
      'date': this.date,
      'paused': this.paused,
      'seconds': this.seconds,
    });
  }

  void deleteDoc(UserStatus user) {
    if (!this.completed) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('uncompleted')
          .doc(this.id)
          .delete();
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completed')
          .doc(this.id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0,
          left: 15,
          right: 15,
          child: Divider(
            height: 0,
            thickness: 1,
          ),
        ),
        Dismissible(
          background: Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.only(left: 15),
            alignment: AlignmentDirectional.centerStart,
            child: Icon(
              FeatherIcons.calendar,
              color: Colors.white,
              size: 20,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            padding: EdgeInsets.only(right: 15),
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
                    padding: const EdgeInsets.only(left: 15, right: 15),
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
                    width: SizeConfig.safeWidth - 65,
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
