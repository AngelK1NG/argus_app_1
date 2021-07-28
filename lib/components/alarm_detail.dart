import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:vivi/components/header.dart';
import 'package:vivi/components/footer.dart';
import 'package:vivi/components/leaderboard_item.dart';
import 'package:vivi/utils/auth.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/constants.dart';

class AlarmDetail extends StatefulWidget {
  final String id;

  AlarmDetail({
    @required this.id,
    Key key,
  }) : super(key: key);

  @override
  _AlarmDetailState createState() => _AlarmDetailState();
}

class _AlarmDetailState extends State<AlarmDetail> {
  DatabaseReference _db = FirebaseDatabase.instance.reference();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _name = '';
  TimeOfDay _time = TimeOfDay.now();
  bool _enabled = true;
  List<LeaderboardItem> _leaderboard = [];

  void getAlarm() {
    List<LeaderboardItem> leaderboard = [];
    var user = context.read<UserStatus>();
    _db.child('alarms').child(widget.id).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> value = snapshot.value;
      _name = value['name'];
      _time = TimeOfDay(hour: value['hour'], minute: value['minute']);
      _enabled = value['members'][user.uid]['enabled'];
      Map<dynamic, dynamic> members = value['members'];
      // SplayTreeMap sorted = SplayTreeMap.from(
      //   members,
      //   (a, b) {
      //     var result = members[a]['score'].compareTo(members[b]['score']);
      //     print(result);
      //     return result == 0 ? 1 : result;
      //   },
      // );
      var sortedKeys = members.keys.toList(growable: false)
        ..sort((a, b) => -members[a]['score'].compareTo(members[b]['score']));
      LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => members[k],
      );
      sortedMap.forEach((key, value) {
        leaderboard.add(LeaderboardItem(
          place: leaderboard.length + 1,
          score: value['score'],
          name: value['name'],
          self: key == user.uid,
        ));
      });
      setState(() {
        _leaderboard = leaderboard;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getAlarm();
  }

  @override
  Widget build(BuildContext context) {
    var user = context.read<UserStatus>();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Color(0xffa6dae8),
            Color(0xffdce5e8),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 15),
          child: Container(
            height: SizeProvider.safeHeight - 30,
            width: SizeProvider.safeWidth - 30,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  spreadRadius: -5,
                  color: Theme.of(context).shadowColor,
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Header(
                      title: '',
                    ),
                    Footer(
                      redString: 'Leave',
                      redOnTap: () {
                        Navigator.of(context).pop();
                      },
                      blackString: 'Done',
                      blackOnTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, top: 100),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: _time.hour == 0 || _time.hour == 12
                                  ? '12:' +
                                      _time.minute.toString().padLeft(2, '0')
                                  : _time.hour.remainder(12).toString() +
                                      ':' +
                                      _time.minute.toString().padLeft(2, '0'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
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
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _name,
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
                      Text(
                        widget.id,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Column(
                          children: _leaderboard,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
