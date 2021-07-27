import 'package:flutter/material.dart';
import 'package:vivi/constants.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/components/footer.dart';

class AddOverlay extends StatefulWidget {
  final Function goToPage;

  AddOverlay({
    @required this.goToPage,
    Key key,
  }) : super(key: key);

  @override
  _AddOverlayState createState() => _AddOverlayState();
}

class _AddOverlayState extends State<AddOverlay> {
  bool _visible = false;

  void pop() {
    if (_visible) {
      setState(() {
        _visible = false;
      });
      Future.delayed(overlayDuration, () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_visible) {
          setState(() {
            _visible = false;
          });
          Future.delayed(overlayDuration, () {
            Navigator.of(context).pop();
          });
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            AnimatedOpacity(
              opacity: _visible ? 0.2 : 0,
              duration: overlayDuration,
              curve: overlayCurve,
              child: GestureDetector(
                onTap: () => pop(),
                child: SizedBox.expand(
                  child: Container(color: black),
                ),
              ),
            ),
            Center(
              child: AnimatedOpacity(
                duration: overlayDuration,
                curve: overlayCurve,
                opacity: _visible ? 1 : 0,
                child: Container(
                  height: 50,
                  width: SizeProvider.safeWidth - 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Footer(
                    redString: 'Create alarm',
                    redOnTap: () {
                      Navigator.of(context).pop();
                      widget.goToPage(2);
                    },
                    blackString: 'Join alarm',
                    blackOnTap: () {
                      Navigator.of(context).pop();
                      widget.goToPage(3);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
