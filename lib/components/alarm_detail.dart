import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vivi/components/header.dart';
import 'package:vivi/components/footer.dart';
import 'package:vivi/components/leaderboard_item.dart';
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
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
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
                      title: '21h 19m remaining',
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
                              text: '7:00',
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
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
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
                      Text(
                        'a84930',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Column(
                          children: [
                            LeaderboardItem(
                              place: 1,
                              score: 727,
                              name: 'Justin',
                              self: true,
                              photoURL:
                                  'https://justinsun.me/static/ec79ca2aed51046658a46fd598c54629/f3583/Profile.png',
                            ),
                            LeaderboardItem(
                              place: 2,
                              score: 420,
                              name: 'Stella',
                              self: false,
                              photoURL: 'https://imgur.com/jZAuzkJ.jpg',
                            ),
                            LeaderboardItem(
                              place: 3,
                              score: 69,
                              name: 'Angel',
                              self: false,
                              photoURL: 'https://i.imgur.com/eeB1kK0.jpg',
                            ),
                          ],
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
