import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/date.dart';
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

  Future<void> updateDoc(UserStatus user) async {
    await FirebaseFirestore.instance
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
    });
  }

  Future<void> addDoc(UserStatus user) async {
    await FirebaseFirestore.instance
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

  Future<void> deleteDoc(UserStatus user) async {
    if (!this.completed) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('uncompleted')
          .doc(this.id)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completed')
          .doc(this.id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(
        color: Theme.of(context).accentColor,
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
        child: Column(
          children: [
            Container(
              height: 50,
              width: SizeProvider.safeWidth,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
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
                            color: Theme.of(context).accentColor,
                          ),
                  ),
                  SizedBox(
                    width: this.date.isNotEmpty &&
                            DateTime.parse(this.date)
                                .isBefore(DateProvider().today)
                        ? SizeProvider.safeWidth - 115
                        : SizeProvider.safeWidth - 65,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        this.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: this.completed
                            ? TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).hintColor,
                              )
                            : TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                      ),
                    ),
                  ),
                  !this.completed &&
                          this.date.isNotEmpty &&
                          DateTime.parse(date).isBefore(DateProvider().today)
                      ? Container(
                          width: 50,
                          child: Text(
                            '${DateProvider().monthString(DateTime.parse(date), false)} ${DateTime.parse(date).day}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              color: red,
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
