import 'package:flutter/material.dart';
import 'package:Focal/components/button.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/constants.dart';

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
      children: [
        end
            ? Image(
                image: AssetImage('assets/images/Logo Large Light.png'),
                width: 300,
              )
            : Icon(
                iconData,
                color: Theme.of(context).accentColor,
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
              color: Theme.of(context).accentColor,
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
          child: Button(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            width: SizeProvider.safeWidth - 100,
            color: Theme.of(context).accentColor,
            row: Row(
              children: [
                Text(
                  'Let\'s go!',
                  style: buttonTextStyle,
                )
              ],
            ),
            vibrate: true,
          ),
        ),
      ],
    );
  }
}
