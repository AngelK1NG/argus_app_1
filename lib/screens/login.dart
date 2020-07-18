import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../components/wrapper.dart';
import '../components/rct_button.dart';
import 'package:Focal/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    auth.onAuthStateChanged.listen((user) {
      Provider.of<User>(context, listen: false).user = user;
      if (user == null) {
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        Navigator.pushNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
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
                    _isLoading = true;
                  });
                  FirebaseUser user = await AuthProvider().googleSignIn();
                  FirestoreProvider(user).createUserDocument();
                  setState(() {
                    _isLoading = false;
                  });
                },
                buttonWidth: 315,
                buttonColor: Colors.white,
                textColor: Colors.black,
                buttonText: "Sign in with Google",
                textSize: 24,
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: RctButton(
                onTap: () {},
                buttonWidth: 315,
                buttonColor: Colors.black,
                textColor: Colors.black,
                buttonText: "Sign in with Apple",
                textSize: 24,
                icon: FaIcon(
                  FontAwesomeIcons.apple,
                  size: 38,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
