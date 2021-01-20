import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/overlay_header.dart';
import 'package:Focal/components/menu_item.dart';
import 'package:Focal/utils/date.dart';

class ScheduleOverlay extends StatefulWidget {
  final DateTime date;
  final Function setDate;
  final VoidCallback onPop;

  ScheduleOverlay({
    @required this.date,
    @required this.setDate,
    @required this.onPop,
    Key key,
  }) : super(key: key);

  @override
  _ScheduleOverlayState createState() => _ScheduleOverlayState();
}

class _ScheduleOverlayState extends State<ScheduleOverlay> {
  bool _visible = false;
  DateTime _date;

  void pop() {
    if (_visible) {
      setState(() {
        _visible = false;
      });
      Future.delayed(overlayDuration, () {
        Navigator.of(context).pop();
      });
      widget.onPop();
    }
  }

  @override
  void initState() {
    super.initState();
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
              bottom:
                  _visible ? 0 : -565 - MediaQuery.of(context).padding.bottom,
              duration: overlayDuration,
              curve: overlayCurve,
              child: AnimatedContainer(
                duration: overlayDuration,
                curve: overlayCurve,
                height: 565 + MediaQuery.of(context).padding.bottom,
                decoration: BoxDecoration(
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    OverlayHeader(
                      title: 'Schedule',
                      leftText: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      leftOnTap: () => pop(),
                      rightText: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      rightOnTap: () {
                        if (_visible) {
                          widget.setDate(_date);
                        }
                        pop();
                      },
                    ),
                    MenuItem(
                      iconData: FeatherIcons.sun,
                      iconColor: Theme.of(context).primaryColor,
                      check: _date == DateProvider().today,
                      text: 'Today',
                      secondaryText: DateProvider()
                          .weekdayString(DateProvider().today, false),
                      onTap: () {
                        if (_visible) {
                          widget.setDate(DateProvider().today);
                        }
                        pop();
                      },
                    ),
                    MenuItem(
                      iconData: FeatherIcons.sunrise,
                      iconColor: Theme.of(context).primaryColor,
                      check: _date == DateProvider().tomorrow,
                      text: 'Tomorrow',
                      secondaryText: DateProvider()
                          .weekdayString(DateProvider().tomorrow, false),
                      onTap: () {
                        if (_visible) {
                          widget.setDate(DateProvider().tomorrow);
                        }
                        pop();
                      },
                    ),
                    MenuItem(
                      iconData: FeatherIcons.calendar,
                      iconColor: Theme.of(context).primaryColor,
                      check: _date == DateProvider().nextWeek,
                      text: 'Next Week',
                      secondaryText: DateProvider()
                          .weekdayString(DateProvider().nextWeek, false),
                      onTap: () {
                        if (_visible) {
                          widget.setDate(DateProvider().nextWeek);
                        }
                        pop();
                      },
                    ),
                    MenuItem(
                      iconData: FeatherIcons.xCircle,
                      iconColor: Theme.of(context).primaryColor,
                      check: _date == null,
                      text: 'No Date',
                      onTap: () {
                        if (_visible) {
                          widget.setDate(null);
                        }
                        pop();
                      },
                    ),
                    SfDateRangePicker(
                      view: DateRangePickerView.month,
                      minDate: DateProvider().today,
                      enablePastDates: false,
                      toggleDaySelection: true,
                      initialSelectedDate: _date,
                      onSelectionChanged:
                          (DateRangePickerSelectionChangedArgs args) {
                        setState(() {
                          _date = args.value;
                        });
                      },
                      headerStyle: DateRangePickerHeaderStyle(
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                          color: black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Cabin',
                        ),
                      ),
                      headerHeight: 50,
                      selectionTextStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: white,
                        fontFamily: 'Cabin',
                      ),
                      monthCellStyle: DateRangePickerMonthCellStyle(
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: black,
                          fontFamily: 'Cabin',
                        ),
                        todayTextStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'Cabin',
                        ),
                        todayCellDecoration: BoxDecoration(),
                        disabledDatesTextStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                          fontFamily: 'Cabin',
                        ),
                      ),
                      yearCellStyle: DateRangePickerYearCellStyle(
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: black,
                          fontFamily: 'Cabin',
                        ),
                        todayTextStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'Cabin',
                        ),
                        todayCellDecoration: BoxDecoration(),
                        disabledDatesTextStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                          fontFamily: 'Cabin',
                        ),
                        leadingDatesTextStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                          fontFamily: 'Cabin',
                        ),
                      ),
                      monthViewSettings: DateRangePickerMonthViewSettings(
                        viewHeaderStyle: DateRangePickerViewHeaderStyle(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Cabin',
                          ),
                        ),
                      ),
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
