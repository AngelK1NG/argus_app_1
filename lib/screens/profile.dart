import 'package:Focal/constants.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:Focal/components/settings_tile.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

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

  void openFeedbackForm() async {
    const URL = 'https://forms.gle/bjAmY4r6TGTC9ybe7';
    if (await canLaunch(URL)) {
      await launch(URL);
    } else {
      print('Couldn\'t find url');
    }
  }

  @override
  void initState() {
    super.initState();
    _name = Provider.of<User>(context, listen: false).user.displayName;
    _email = Provider.of<User>(context, listen: false).user.email;
    _photoUrl = Provider.of<User>(context, listen: false).user.photoUrl;
    db
        .collection('users')
        .document(Provider.of<User>(context, listen: false).user.uid)
        .get()
        .then((snapshot) {
      if (mounted) {
        setState(() {
          _totalFocused = Duration(seconds: snapshot.data['secondsFocused']);
          _avgFocused = Duration(
              seconds: snapshot.data['secondsFocused'] ~/
                  snapshot.data['daysActive']);
          _totalTasks = snapshot.data['completedTasks'];
          _avgTasks =
              snapshot.data['completedTasks'] ~/ snapshot.data['daysActive'];
          _loading = false;
        });
      }
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
      fontSize: 14,
      color: Theme.of(context).primaryColor,
    );
    TextStyle redStatDescriptionTextStyle = TextStyle(
      fontSize: 14,
      color: Colors.red,
    );

    return WillPopScope(
      onWillPop: () => widget.goToPage(0),
      child: Stack(children: <Widget>[
        Positioned(
          left: 25,
          top: SizeConfig.safeBlockVertical * 5,
          child: Text(
            'Profile',
            style: headerTextStyle,
          ),
        ),
        Positioned(
          top: SizeConfig.safeBlockVertical * 15 + 25,
          left: 25,
          right: 25,
          child: SizedBox(
            height: SizeConfig.safeBlockVertical * 85 - 105,
            child: AnimatedOpacity(
              opacity: _loading ? 0 : 1,
              duration: loadingDuration,
              curve: loadingCurve,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    Offstage(
                      offstage: _name == null,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 25),
                        child: SizedBox(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    _name == null ? '' : _name,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _email == null ? '' : _email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _totalFocused.inHours.toString() +
                                  'h ' +
                                  (_totalFocused.inMinutes % 60).toString() +
                                  'm',
                              style: statTextStyle,
                            ),
                            Text(
                              'Total Focused',
                              style: blueStatDescriptionTextStyle,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                _avgFocused.inHours.toString() +
                                    'h ' +
                                    (_avgFocused.inMinutes % 60).toString() +
                                    'm',
                                style: statTextStyle,
                              ),
                            ),
                            Text(
                              'Avg. Focused',
                              style: redStatDescriptionTextStyle,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              _totalTasks.toString(),
                              style: statTextStyle,
                            ),
                            Text(
                              'Total Tasks Completed',
                              style: blueStatDescriptionTextStyle,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                _avgTasks.toString(),
                                style: statTextStyle,
                              ),
                            ),
                            Text(
                              'Avg. Tasks Completed',
                              style: redStatDescriptionTextStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Settings',
                              style: statTextStyle,
                            ),
                          ),
                          SettingsTile(
                            iconData: FeatherIcons.settings,
                            text: 'General',
                            chevron: true,
                            divider: true,
                            onTap: () => widget.goToPage(4),
                          ),
                          SettingsTile(
                            iconData: FeatherIcons.archive,
                            text: 'Feedback',
                            chevron: true,
                            divider: true,
                            onTap: () => openFeedbackForm(),
                          ),
                          SettingsTile(
                            iconData: FeatherIcons.helpCircle,
                            text: 'Help',
                            chevron: true,
                            divider: true,
                            onTap: () => widget.goToPage(5),
                          ),
                          SettingsTile(
                            iconData: FeatherIcons.info,
                            text: 'About',
                            chevron: true,
                            divider: true,
                            onTap: () => widget.goToPage(6),
                          ),
                          SettingsTile(
                            iconData: FeatherIcons.logOut,
                            text: 'Sign Out',
                            chevron: false,
                            divider: false,
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              auth.signOut();
                              AnalyticsProvider().logSignOut();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
