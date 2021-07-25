import 'dart:typed_data';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/utils/auth.dart';
import 'package:vivi/utils/date.dart';
import 'package:vivi/constants.dart';

class Alarm extends StatefulWidget {
  final String name;
  final DateTime time;
  final bool enabled;
  final bool sunday;
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final String id;
  final Function onTap;

  const Alarm({
    @required this.name,
    @required this.time,
    @required this.enabled,
    @required this.sunday,
    @required this.monday,
    @required this.tuesday,
    @required this.wednesday,
    @required this.thursday,
    @required this.friday,
    @required this.saturday,
    @required this.id,
    @required this.onTap,
    Key key,
  }) : super(key: key);

  factory Alarm.fromFirestore(DocumentSnapshot doc, bool completed) {
    Map data = doc.data();
    // return Alarm(
    //   id: doc.id,
    //   index: data['index'] ?? 0,
    //   name: data['name'] ?? '',
    //   date: data['date'] != null ? data['date'].toDate() : null,
    //   completed: completed,
    //   paused: data['paused'] ?? false,
    //   seconds: data['seconds'] ?? 0,
    // );
  }

  @override
  _AlarmState createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: AnimatedContainer(
        height: 130,
        width: SizeProvider.safeWidth - 30,
        padding: EdgeInsets.only(left: 15, right: 15),
        duration: fadeDuration,
        curve: fadeCurve,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: _enabled
              ? [
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: -5,
                    color: Theme.of(context).shadowColor,
                  ),
                ]
              : [
                  BoxShadow(
                    blurRadius: 0,
                    spreadRadius: -5,
                    color: Theme.of(context).shadowColor,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: '7:00',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                    children: [
                      TextSpan(
                        text: ' AM',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 10),
                  child: Row(
                    children: [
                      Text(
                        'Friends',
                        style: TextStyle(fontSize: 16),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: RichText(
                          text: TextSpan(
                            text: '2',
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).accentColor,
                                    ),
                            children: [
                              TextSpan(
                                text: '/6',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'S',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).accentColor,
                        ),
                    children: [
                      TextSpan(
                        text: ' M',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      TextSpan(
                        text: ' T',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      TextSpan(
                        text: ' W',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      TextSpan(
                        text: ' T',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      TextSpan(
                        text: ' F',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      TextSpan(
                        text: ' S',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            CupertinoSwitch(
              value: _enabled,
              onChanged: (value) {
                setState(() {
                  _enabled = value;
                });
                HapticFeedback.heavyImpact();
              },
              activeColor: Theme.of(context).accentColor,
              trackColor: Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
