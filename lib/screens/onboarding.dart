import 'package:flutter/material.dart';
import 'package:Focal/components/wrapper.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:Focal/components/onboarding_page.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  PageController _controller = PageController(
    initialPage: 0,
  );
  double _index = 0;
  TextStyle descriptionStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
  );

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
    return WillPopScope(
      onWillPop: () async => false,
      child: WrapperWidget(
        nav: false,
        staticChild: Stack(
          children: <Widget>[
            PageView(
              controller: _controller,
              children: <Widget>[
                OnboardingPage(
                  title: 'Focus',
                  text: Text.rich(
                    TextSpan(
                      style: descriptionStyle,
                      children: <TextSpan>[
                        TextSpan(
                          text: 'This is where you will focus! Tap ',
                        ),
                        TextSpan(
                          text: 'Start',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: ' to begin the stopwatch for the current task. Tap ',
                        ),
                        TextSpan(
                          text: 'Done',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: ' when you’re done, the ',
                        ),
                        TextSpan(
                          text: 'Pause Button',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        TextSpan(
                          text: ' to pause, or ',
                        ),
                        TextSpan(
                          text: 'Save for later',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        TextSpan(
                          text: ' to defer the task.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  button: false,
                ),
                OnboardingPage(
                  title: 'Prioritize',
                  text: Text(
                    'Start the day by ordering your tasks based on what you need to get done first. You can hold to reorder or swipe to remove any task.',
                    textAlign: TextAlign.center,
                    style: descriptionStyle,
                  ),
                  button: false,
                ),
                OnboardingPage(
                  title: 'Statistics',
                  text: Text.rich(
                    TextSpan(
                      style: descriptionStyle,
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Discover how much time you spent being productive with statistics. When you leave the app while ',
                        ),
                        TextSpan(
                          text: 'Focused',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: ', you become ',
                        ),
                        TextSpan(
                          text: 'Distracted',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                        TextSpan(
                          text: '. Otherwise, tap the ',
                        ),
                        TextSpan(
                          text: 'Pause Button',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        TextSpan(
                          text: ' to become ',
                        ),
                        TextSpan(
                          text: 'Paused',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        TextSpan(
                          text: '.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  button: false,
                ),
                OnboardingPage(
                  title: 'Ready up',
                  text: Text(
                    'Let\'s get focused! 🚀',
                    textAlign: TextAlign.center,
                    style: descriptionStyle,
                  ),
                  button: true,
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
                  activeColor: Theme.of(context).accentColor,
                  shape: CircleBorder(side: BorderSide(color: Theme.of(context).accentColor, width: 2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}