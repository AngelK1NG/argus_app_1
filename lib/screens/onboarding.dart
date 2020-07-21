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
        child: Stack(
          children: <Widget>[
            PageView(
              controller: _controller,
              children: <Widget>[
                OnboardingPage(
                  title: 'Welcome',
                  text: 'You have been invited to test Focal in our closed Alpha! In the next few pages we will take you through the basics of app to get you started.',
                  button: false,
                ),
                OnboardingPage(
                  title: 'Navigate',
                  text: 'Use the navigation bar to access all of Focal’s features!',
                  button: false,
                ),
                OnboardingPage(
                  title: 'Home',
                  text: 'This is where you will complete all of your tasks! Click start to begin your task at hand and the stopwatch will start.',
                  button: false,
                ),
                OnboardingPage(
                  title: 'Focus',
                  text: 'Once you finish, tap Complete. If you failed to complete the task, tap Abandon to start your next task.',
                  button: false,
                ),
                OnboardingPage(
                  title: 'Prioritize',
                  text: 'Start the day by ordering your tasks based on what you need to get done first. Hold anywhere on the screen to drag and reorder your list. The task at the top will be shown first in Focus. You can also swipe to remove any tasks.',
                  button: false,
                ),
                OnboardingPage(
                  title: 'Calendar',
                  text: 'Use the calendar to schedule future tasks as well as access task history.',
                  button: false,
                ),
                OnboardingPage(
                  title: 'Statistics',
                  text: 'At any point of the day, you can always check your stats to see the total time you were being productive, how many tasks you have completed, and the percentage of tasks you have completed ',
                  button: false,
                ),
                OnboardingPage(
                  title: 'Feedback',
                  text: 'When you are ready, please fill out a feedback form that could be found at the bottom of the navigation bar. We will also be contacting you for more details.',
                  button: true,
                ),
                
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: DotsIndicator(
                dotsCount: 8,
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