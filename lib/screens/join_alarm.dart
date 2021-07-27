import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vivi/components/header.dart';
import 'package:vivi/components/footer.dart';
import 'package:vivi/utils/auth.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/constants.dart';

class JoinAlarmPage extends StatefulWidget {
  final Function goToPage;

  JoinAlarmPage({
    @required this.goToPage,
    Key key,
  }) : super(key: key);

  @override
  _JoinAlarmPageState createState() => _JoinAlarmPageState();
}

class _JoinAlarmPageState extends State<JoinAlarmPage> {
  DatabaseReference _db = FirebaseDatabase.instance.reference();
  String _id = '';

  void submit() async {
    var user = context.read<UserStatus>();
    DataSnapshot snapshot = await _db.child('alarms').child(_id).once();
    if (snapshot != null) {
      await _db.child('alarms').child(_id).child('members').set({
        user.uid: {
          'enabled': true,
          'name': user.displayName,
          'score': 0,
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    title: 'Join alarm',
                  ),
                  Footer(
                    redString: 'Cancel',
                    redOnTap: () {
                      this.widget.goToPage(0);
                    },
                    blackString: 'Join',
                    blackOnTap: () async {
                      await submit();
                      this.widget.goToPage(0);
                    },
                  ),
                ],
              ),
              Center(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Alarm ID",
                  ),
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  keyboardAppearance: MediaQuery.of(context).platformBrightness,
                  onChanged: (value) {
                    _id = value;
                  },
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  onFieldSubmitted: (_) async {
                    await submit();
                    this.widget.goToPage(0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
