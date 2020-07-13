import 'package:Focal/utils/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Components/RctButton.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("Images/Focal Logo_Full.png")),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: RctButton(
              onTap: () async {
                bool res = await AuthProvider().googleSignIn();
                if (!res)
                  print('error logging in with google');
                else {
                  Navigator.pushNamed(context, '/');
                }
              },
              buttonWidth: 300,
              buttonColor: Colors.white,
              textColor: Colors.black,
              buttonText: "Sign in with Google",
              textSize: 24,
              icon: FaIcon(
                FontAwesomeIcons.google,
                size: 32,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: RctButton(
              onTap: () {},
              buttonWidth: 300,
              buttonColor: Colors.black,
              textColor: Colors.black,
              buttonText: "Sign in with Apple",
              textSize: 24,
              icon: FaIcon(
                FontAwesomeIcons.apple,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
