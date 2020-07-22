import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/local_notifications.dart';
import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../components/wrapper.dart';
import '../components/rct_button.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loginLoading = false;
  bool _isLoading = true;
  bool _isLogin = false;
  @override
  void initState() {
    super.initState();
    auth.onAuthStateChanged.listen((user) {
      Provider.of<User>(context, listen: false).user = user;
      if (user == null) {
        setState(() {
          _isLogin = true;
          _isLoading = false;
        });
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      } else {
        FirestoreProvider(user).userDocumentExists().then((exists) {
          setState(() {
            _isLoading = false;
          });
          if (exists) {
            Future.delayed(Duration(milliseconds: 1000), () {
              Navigator.pushNamed(context, '/home');
            });
          } else {
            Future.delayed(Duration(milliseconds: 1000), () {
              Navigator.pushNamed(context, '/onboarding');
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
        ),
        Visibility(
          visible: _isLogin,
          child: ModalProgressHUD(
            inAsyncCall: _loginLoading,
            child: WrapperWidget(
              nav: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(image: AssetImage('images/Focal Logo_Full.png')),
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: RctButton(
                      onTap: () async {
                        setState(() {
                          _loginLoading = true;
                        });
                        AuthProvider().googleSignIn();
                        setState(() {
                          _loginLoading = false;
                        });
                        LocalNotificationHelper.userLoggedIn = true;
                      },
                      buttonWidth: 315,
                      buttonColor: Colors.black,
                      textColor: Colors.white,
                      buttonText: "Sign in with Google",
                      textSize: 24,
                      icon: FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: !_isLogin,
          child: AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0,
            duration: Duration(milliseconds: 1000),
            child: Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Image(image: AssetImage('images/Focal Logo_Full.png')),
            ),
          ),
        ),
      ],
    );
  }
}
