import 'package:flutter/material.dart';
import 'nav_burger.dart';
import 'side_nav.dart';

class WrapperWidget extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final bool nav;
  final bool loading;
  final bool transition;

  const WrapperWidget({@required this.child, this.backgroundColor, this.nav, @required this.loading, @required this.transition});

  @override
  _WrapperWidgetState createState() => _WrapperWidgetState();
}

class _WrapperWidgetState extends State<WrapperWidget> {
  bool _navActive = false;
  bool _offstage = false;

  void toggleNav() {
    setState(() {
      _navActive = !_navActive;
    });
  }
  
  void toggleOffstage() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (this.mounted) {
        setState(() => _offstage = true);
      }
    });
  }

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.loading) {
      toggleOffstage();
    }
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
                GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  onTap: () {
                    setState(() {
                      _navActive = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.ease,
                    color: widget.backgroundColor,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: _navActive ? 0.5 : 1,
                      child: SafeArea(
                        child: AbsorbPointer(
                          absorbing: _navActive,
                          child: Container(
                            child: widget.child
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Offstage(
                  offstage: _offstage || !widget.transition,
                  child: AnimatedOpacity(
                    opacity: widget.loading ? 1 : 0,
                    duration: Duration(milliseconds: 200),
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ),
                SideNav(onTap: toggleNav, active: _navActive,),
                SafeArea(
                  child: Offstage(
                    offstage: !widget.nav,
                    child: NavBurger(onTap: () {
                      toggleNav();
                      FocusScope.of(context).unfocus();
                    }, active: _navActive),
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