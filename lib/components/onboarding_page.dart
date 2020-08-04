import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/components/rct_button.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/user.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final Text text;
  final bool button;

  const OnboardingPage({
    @required this.title,
    @required this.text,
    this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image(
            image: AssetImage('images/onboarding/' + title + '.png'),
            height: 225),
        Padding(
          padding: const EdgeInsets.only(
            top: 50,
            bottom: 25,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(
            bottom: 50,
          ),
          width: 315,
          child: text,
        ),
        Offstage(
          offstage: !button,
          child: RctButton(
            onTap: () {
              FirebaseUser user =
                  Provider.of<User>(context, listen: false).user;
              FirestoreProvider(user).createUserDocument();
              Navigator.pushReplacementNamed(context, '/home');
            },
            buttonWidth: 220,
            colored: true,
            buttonText: 'Let\'s go!',
            textSize: 28,
          ),
        ),
      ],
    );
  }
}
