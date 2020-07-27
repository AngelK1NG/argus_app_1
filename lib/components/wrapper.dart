import 'package:flutter/material.dart';
import 'nav_burger.dart';
import 'side_nav.dart';
import 'package:Focal/constants.dart';

class WrapperWidget extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final bool nav;
  final bool loading;
  final double cardHeight;

  const WrapperWidget(
      {@required this.child,
      this.backgroundColor,
      this.nav,
      @required this.loading,
      @required this.cardHeight,
    }
  );

  @override
  _WrapperWidgetState createState() => _WrapperWidgetState();
}

class _WrapperWidgetState extends State<WrapperWidget> {
  bool _navActive = false;

  void toggleNav() {
    setState(() {
      _navActive = !_navActive;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        body: SizedBox.expand(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 10 && widget.nav) {
                setState(() {
                  _navActive = true;
                });
                FocusScope.of(context).unfocus();
              }
              if (details.delta.dx < -10 && widget.nav) {
                setState(() {
                  _navActive = false;
                });
                FocusScope.of(context).unfocus();
              }
            },
            child: Stack(
              children: <Widget>[
                AnimatedContainer(
                  duration: cardSlideDuration,
                  curve: cardSlideCurve,
                  color: widget.backgroundColor,
                  child: Container(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: cardSlideDuration,
                    curve: cardSlideCurve,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50),),
                      color: Colors.white,
                    ),
                    height: widget.cardHeight,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  onTap: () {
                    setState(() {
                      _navActive = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                  child: AnimatedOpacity(
                    duration: navDuration,
                    opacity: widget.loading ? 0 : (_navActive ? 0.5 : 1),
                    child: SafeArea(
                      child: AbsorbPointer(
                        absorbing: _navActive,
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
                SideNav(
                  onTap: toggleNav,
                  active: _navActive,
                ),
                SafeArea(
                  child: Offstage(
                    offstage: !widget.nav,
                    child: NavBurger(
                        onTap: () {
                          toggleNav();
                          FocusScope.of(context).unfocus();
                        },
                        active: _navActive),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
