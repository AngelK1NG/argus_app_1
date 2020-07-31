import 'package:flutter/material.dart';
import 'nav_burger.dart';
import 'side_nav.dart';
import 'package:Focal/constants.dart';

class WrapperWidget extends StatefulWidget {
  final Widget staticChild;
  final Widget dynamicChild;
  final Color backgroundColor;
  final bool nav;
  final bool loading;
  final double cardPosition;

  const WrapperWidget({
    this.staticChild,
    this.dynamicChild,
    this.backgroundColor,
    this.nav,
    this.loading,
    this.cardPosition,
  });

  @override
  _WrapperWidgetState createState() => _WrapperWidgetState();
}

class _WrapperWidgetState extends State<WrapperWidget>
    with TickerProviderStateMixin {
  bool _navActive = false;
  bool _loading = true;

  void toggleNav() {
    setState(() {
      _navActive = !_navActive;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _loading = false;
      });
    });
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
                AnimatedPositioned(
                  duration: cardSlideDuration,
                  curve: cardSlideCurve,
                  left: 0,
                  right: 0,
                  top: widget.cardPosition == null
                      ? MediaQuery.of(context).size.height
                      : widget.cardPosition,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: -5,
                          blurRadius: 15,
                        )
                      ],
                    ),
                    height: MediaQuery.of(context).size.height,
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
                    opacity: _loading ? 0 : (_navActive ? 0.5 : 1),
                    child: SafeArea(
                      child: AbsorbPointer(
                        absorbing: _navActive,
                        child: Stack(
                          children: <Widget>[
                            widget.staticChild == null ? Container() : widget.staticChild,
                            Opacity(
                              opacity: widget.loading == true ? 0 : 1,
                              child: AnimatedOpacity(
                                duration: navDuration,
                                curve: navCurve,
                                opacity: widget.loading == true ? 0 : 1,
                                child: widget.dynamicChild == null ? Container() : widget.dynamicChild,
                              ),
                            )
                          ],
                        ),
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
