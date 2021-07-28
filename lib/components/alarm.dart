import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:vivi/utils/auth.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/constants.dart';
import 'package:vivi/components/alarm_detail.dart';

class Alarm extends StatefulWidget {
  final String id;
  final String name;
  final TimeOfDay time;
  final bool enabled;
  final int place;
  final int total;

  const Alarm({
    @required this.id,
    @required this.name,
    @required this.time,
    @required this.enabled,
    this.place,
    this.total,
    Key key,
  }) : super(key: key);

  @override
  _AlarmState createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  DatabaseReference _db = FirebaseDatabase.instance.reference();
  bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    var user = context.read<UserStatus>();
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              transitionDuration: Duration(seconds: 5),
              pageBuilder: (_, __, ___) {
                return AlarmDetail(
                  id: widget.id,
                );
              },
            ),
          );
        },
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
                      text: widget.time.hour == 0 || widget.time.hour == 12
                          ? '12:' +
                              widget.time.minute.toString().padLeft(2, '0')
                          : widget.time.hour.remainder(12).toString() +
                              ':' +
                              widget.time.minute.toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                      children: [
                        TextSpan(
                          text: widget.time.hour < 12 ? ' AM' : 'PM',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Row(
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(fontSize: 16),
                        ),
                        // Padding(
                        //   padding: EdgeInsets.only(left: 10),
                        //   child: RichText(
                        //     text: TextSpan(
                        //       text: '2',
                        //       style: Theme.of(context)
                        //           .textTheme
                        //           .bodyText1
                        //           .copyWith(
                        //             fontSize: 16,
                        //             fontWeight: FontWeight.w600,
                        //             color: Theme.of(context).accentColor,
                        //           ),
                        //       children: [
                        //         TextSpan(
                        //           text: '/6',
                        //           style: TextStyle(
                        //             fontSize: 12,
                        //             color: Theme.of(context).hintColor,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              CupertinoSwitch(
                value: _enabled,
                onChanged: (value) async {
                  await _db
                      .child('alarms')
                      .child(widget.id)
                      .child('members')
                      .child(user.uid)
                      .child('enabled')
                      .set(value);
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
      ),
    );
  }
}
