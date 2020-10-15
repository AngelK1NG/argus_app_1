import 'package:Focal/constants.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

class ProfilePage extends StatefulWidget {
  final Function goToPage;

  ProfilePage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  String _email;
  String _name;
  String _photoUrl;
  Duration _totalFocused = Duration();
  Duration _avgFocused = Duration();
  int _totalTasks = 0;
  int _avgTasks = 0;

  @override
  void initState() {
    super.initState();
    _name = Provider.of<User>(context, listen: false).user.displayName;
    _email = Provider.of<User>(context, listen: false).user.email;
    _photoUrl = Provider.of<User>(context, listen: false).user.photoUrl;
    db.collection('users').document(Provider.of<User>(context, listen: false).user.uid).get().then((snapshot) {
      setState(() {
        _totalFocused = Duration(seconds: snapshot.data['secondsFocused']);
        _avgFocused = Duration(seconds: snapshot.data['secondsFocused'] ~/ snapshot.data['daysActive']);
        _totalTasks = snapshot.data['completedTasks'];
        _avgTasks = snapshot.data['completedTasks'] ~/ snapshot.data['daysActive'];
        _loading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle statTextStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    );
    TextStyle blueStatDescriptionTextStyle = TextStyle(
      fontSize: 12,
      color: Theme.of(context).primaryColor,
    );
    TextStyle redStatDescriptionTextStyle = TextStyle(
      fontSize: 12,
      color: Colors.red,
    );

    return WillPopScope(
      onWillPop: () async => widget.goToPage(0),
      child: Stack(children: <Widget>[
        Positioned(
          left: 25,
          top: SizeConfig.safeBlockVertical * 5,
          child: Text(
            'Profile',
            style: headerTextStyle,
          ),
        ),
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: loadingDuration,
          curve: loadingCurve,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 25,
                left: 25,
                top: SizeConfig.safeBlockVertical * 15 + 25,
                child: SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _photoUrl == null
                                ? Icon(
                                    FeatherIcons.user,
                                    color: jetBlack,
                                    size: 60,
                                  )
                                : CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(_photoUrl),
                                  ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  _name,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 45,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _totalFocused.inHours.toString() + 'h ' + _totalFocused.inMinutes.toString() + 'm',
                                        style: statTextStyle,
                                      ),
                                      Text(
                                        'Total Focused',
                                        style: blueStatDescriptionTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 45,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _avgFocused.inHours.toString() + 'h ' + _avgFocused.inMinutes.toString() + 'm',
                                        style: statTextStyle,
                                      ),
                                      Text(
                                        'Avg. Focused',
                                        style: redStatDescriptionTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  height: 45,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _totalTasks.toString(),
                                        style: statTextStyle,
                                      ),
                                      Text(
                                        'Total Tasks Completed',
                                        style: blueStatDescriptionTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 45,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _avgTasks.toString(),
                                        style: statTextStyle,
                                      ),
                                      Text(
                                        'Avg. Tasks Completed',
                                        style: redStatDescriptionTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
