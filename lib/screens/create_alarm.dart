import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:vivi/components/header.dart';
import 'package:vivi/components/footer.dart';
import 'package:vivi/utils/auth.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/constants.dart';

class CreateAlarmPage extends StatefulWidget {
  final Function goToPage;

  CreateAlarmPage({
    @required this.goToPage,
    Key key,
  }) : super(key: key);

  @override
  _CreateAlarmPageState createState() => _CreateAlarmPageState();
}

class _CreateAlarmPageState extends State<CreateAlarmPage> {
  DatabaseReference _db = FirebaseDatabase.instance.reference();
  TimeOfDay _time = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);
  String _name = 'Alarm';

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserStatus>(context);
    return WillPopScope(
      onWillPop: () => this.widget.goToPage(0),
      child: Center(
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
                    title: 'Create alarm',
                  ),
                  Footer(
                    redString: 'Cancel',
                    redOnTap: () {
                      this.widget.goToPage(0);
                    },
                    blackString: 'Create',
                    blackOnTap: () {
                      _db.child('alarms').push().set({
                        'name': _name,
                        'hour': _time.hour,
                        'minute': _time.minute,
                        'members': {
                          user.uid: {
                            'enabled': true,
                            'name': user.displayName,
                            'score': 0,
                          }
                        }
                      }).then((_) => this.widget.goToPage(0));
                    },
                  ),
                ],
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 50,
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        'Tap to edit',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay newTime = await showTimePicker(
                          context: context,
                          initialTime: _time,
                        );
                        if (newTime != null) {
                          setState(() {
                            _time = newTime;
                          });
                        }
                      },
                      child: Container(
                        width: 300,
                        height: 100,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            text: _time.hour == 0 || _time.hour == 12
                                ? '12:' +
                                    _time.minute.toString().padLeft(2, '0')
                                : _time.hour.remainder(12).toString() +
                                    ':' +
                                    _time.minute.toString().padLeft(2, '0'),
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w600,
                                    ),
                            children: [
                              TextSpan(
                                text: _time.hour < 12 ? ' AM' : 'PM',
                                style: TextStyle(fontSize: 36),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        width: 100,
                        height: 50,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          _name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
