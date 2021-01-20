import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/components/schedule_overlay.dart';

class AddOverlay extends StatefulWidget {
  final String text;
  final Function setText;
  final DateTime date;
  final Function setDate;
  final Function submit;

  AddOverlay({
    @required this.text,
    @required this.setText,
    @required this.date,
    @required this.setDate,
    @required this.submit,
    Key key,
  }) : super(key: key);

  @override
  _AddOverlayState createState() => _AddOverlayState();
}

class _AddOverlayState extends State<AddOverlay> {
  bool _visible = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController _input = TextEditingController();
  DateTime _date;

  void pop() {
    if (_visible) {
      setState(() {
        _visible = false;
      });
      _focusNode.unfocus();
      Future.delayed(overlayDuration, () {
        Navigator.of(context).pop();
      });
    }
  }

  void submit() {
    _focusNode.requestFocus();
    if (_input.text.isNotEmpty) {
      widget.setText('');
      widget.submit(_input.text);
      setState(() {
        _input.clear();
        _date = DateProvider().today;
      });
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void initState() {
    super.initState();
    _input.text = widget.text;
    _input.selection = TextSelection.fromPosition(
      TextPosition(offset: _input.text.length),
    );
    _date = widget.date;
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
        pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            AnimatedOpacity(
              opacity: _visible ? 0.15 : 0,
              duration: overlayDuration,
              curve: overlayCurve,
              child: GestureDetector(
                onTap: () => pop(),
                child: SizedBox.expand(
                  child: Container(color: black),
                ),
              ),
            ),
            AnimatedPositioned(
              left: 0,
              right: 0,
              bottom: _visible
                  ? 0
                  : -100 - MediaQuery.of(context).viewInsets.bottom,
              duration: overlayDuration,
              curve: overlayCurve,
              child: AnimatedContainer(
                duration: overlayDuration,
                curve: overlayCurve,
                height: 100 + MediaQuery.of(context).viewInsets.bottom,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  color: white,
                  boxShadow: [
                    _visible
                        ? BoxShadow(
                            blurRadius: 10,
                            offset: Offset(0, -4),
                            color: Theme.of(context).shadowColor,
                          )
                        : BoxShadow(color: Colors.transparent)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Container(
                        height: 50,
                        width: SizeProvider.safeWidth - 30,
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Add a new task",
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: black,
                          ),
                          autofocus: true,
                          focusNode: _focusNode,
                          controller: _input,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            setState(() {
                              widget.setText(value);
                            });
                          },
                          onFieldSubmitted: (_) => submit(),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(PageRouteBuilder(
                              opaque: false,
                              transitionDuration: Duration(seconds: 5),
                              pageBuilder: (_, __, ___) {
                                return ScheduleOverlay(
                                  date: _date,
                                  setDate: (date) {
                                    setState(() {
                                      _date = date;
                                    });
                                    widget.setDate(date);
                                  },
                                  onPop: () {
                                    _focusNode.requestFocus();
                                  },
                                );
                              },
                            ));
                          },
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.only(left: 15, right: 15),
                            color: Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  FeatherIcons.calendar,
                                  size: 20,
                                  color: _date == null
                                      ? black
                                      : Theme.of(context).primaryColor,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                    _date == DateProvider().today
                                        ? 'Today'
                                        : _date == DateProvider().tomorrow
                                            ? 'Tomorrow'
                                            : _date == null
                                                ? 'No Date'
                                                : DateProvider().weekdayString(
                                                    _date,
                                                    true,
                                                  ),
                                    style: TextStyle(
                                      color: _date == null
                                          ? black
                                          : Theme.of(context).primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => submit(),
                          child: Container(
                            height: 50,
                            width: 50,
                            color: Colors.transparent,
                            child: Icon(
                              FeatherIcons.arrowUp,
                              size: 20,
                              color: _input.text.isEmpty
                                  ? Theme.of(context).hintColor
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
