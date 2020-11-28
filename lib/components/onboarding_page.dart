import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/components/rct_button.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/user.dart';

class OnboardingPage extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Text text;
  final bool end;

  const OnboardingPage({
    this.iconData,
    @required this.title,
    this.text,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        end
            ? Image(
                image: AssetImage(
                    'assets/images/logo/Focal Logo_Full Colored.png'),
                width: 300,
              )
            : Icon(
                iconData,
                color: Theme.of(context).primaryColor,
                size: 150,
              ),
        Padding(
          padding: const EdgeInsets.only(
            top: 100,
            bottom: 50,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
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
          offstage: !end,
          child: RctButton(
            onTap: () {
              FirebaseUser user =
                  Provider.of<User>(context, listen: false).user;
              FirestoreProvider(user).createUserDocument();
              Navigator.pushReplacementNamed(context, '/home');
            },
            buttonWidth: 200,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            buttonText: 'Let\'s go!',
            textSize: 28,
            vibrate: true,
          ),
        ),
      ],
    );
  }
}
