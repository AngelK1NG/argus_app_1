import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:Focal/components/onboarding_page.dart';
import 'package:Focal/constants.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

class OnboardingIntro extends StatefulWidget {
  const OnboardingIntro({Key key}) : super(key: key);

  @override
  _OnboardingIntroState createState() => _OnboardingIntroState();
}

class _OnboardingIntroState extends State<OnboardingIntro> {
  PageController _controller = PageController(
    initialPage: 0,
  );
  double _index = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.page != _index) {
        setState(() {
          _index = _controller.page;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle descriptionStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          if (_index > 0) {
            _index--;
            _controller.animateToPage(
              _index.round(),
              duration: generalDuration,
              curve: generalCurve,
            );
          }
          return false;
        },
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              PageView(
                controller: _controller,
                children: <Widget>[
                  OnboardingPage(
                    iconData: FeatherIcons.list,
                    title: 'Tasks',
                    text: Text.rich(
                      TextSpan(
                        style: descriptionStyle,
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                'Focal streamlines your workflow. Simply add and order your tasks based on priority and get ',
                          ),
                          TextSpan(
                            text: 'Focused',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' immediately, or schedule tasks due in the future.',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    end: false,
                  ),
                  OnboardingPage(
                    iconData: FeatherIcons.clock,
                    title: 'Focus',
                    text: Text.rich(
                      TextSpan(
                        style: descriptionStyle,
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Focus',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' on the task at hand by staying on Focal. When you leave the app while completing a task, Focal will notify you to return and track your time as ',
                          ),
                          TextSpan(
                            text: 'Distracted',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          TextSpan(
                            text: '.',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    end: false,
                  ),
                  OnboardingPage(
                    iconData: FeatherIcons.percent,
                    title: 'Statistics',
                    text: Text.rich(
                      TextSpan(
                        style: descriptionStyle,
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                'Volts, Focal\'s score system, are a reflection of your productivity over time. To maximize your Volts avoid getting ',
                          ),
                          TextSpan(
                            text: 'Distracted',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          TextSpan(
                            text:
                                '. Volts will decay over time until completion of every task.',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    end: false,
                  ),
                  OnboardingPage(
                    title: 'Ready?',
                    end: true,
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: DotsIndicator(
                  dotsCount: 4,
                  position: _index,
                  decorator: DotsDecorator(
                    color: Colors.transparent,
                    activeColor: Theme.of(context).primaryColor,
                    shape: CircleBorder(
                        side: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
