import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/volts.dart';
import 'package:Focal/components/volts_chart.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ShareStatistics extends StatefulWidget {
  final Function goToPage;
  final Volts volts;
  final List<Volts> voltsList;
  final Duration timeFocused;
  final int index;

  const ShareStatistics({
    @required this.goToPage,
    @required this.volts,
    @required this.voltsList,
    @required this.timeFocused,
    @required this.index,
  });

  @override
  _ShareStatisticsState createState() => _ShareStatisticsState();
}

class _ShareStatisticsState extends State<ShareStatistics> {
  ScreenshotController _screenshotController = ScreenshotController();
  NumberFormat voltsFormat = NumberFormat('###,##0.00');
  bool _loading = true;

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
    return WillPopScope(
      onWillPop: () => widget.goToPage(2),
      child: Stack(
        children: [
          Positioned(
            right: 25,
            left: 25,
            top: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => widget.goToPage(2),
                  child: Container(
                    width: 60,
                    height: 40,
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.heavyImpact();
                    final directory =
                        (await getApplicationDocumentsDirectory()).path;
                    String fileName = DateTime.now().toIso8601String();
                    String path = '$directory/$fileName.png';
                    _screenshotController
                        .capture(
                      path: path,
                      pixelRatio: 3,
                    )
                        .then((_) {
                      Share.shareFiles(
                        [path],
                        text:
                            'Join me on Focal to get things done, one task at a time! https://focal.technology',
                      );
                    }).catchError((onError) {
                      print(onError);
                    });
                  },
                  child: Container(
                    width: 110,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      color: widget.voltsList.length == 0
                          ? Theme.of(context).primaryColor
                          : widget.volts.val >= widget.voltsList.first.val
                              ? Theme.of(context).primaryColor
                              : Colors.red,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          FeatherIcons.share,
                          size: 14,
                          color: Colors.white,
                        ),
                        Text(
                          'Share Stats',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Screenshot(
              controller: _screenshotController,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: _loading ? 0 : 1,
                      duration: cardDuration,
                      curve: cardCurve,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 25),
                                      child: Icon(
                                        FeatherIcons.zap,
                                        size: 30,
                                        color: jetBlack,
                                      ),
                                    ),
                                    Text(
                                      voltsFormat.format(widget.volts.val),
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 25, top: 15),
                                  child: Row(
                                    children: [
                                      Icon(
                                        widget.volts.val >=
                                                widget.voltsList.first.val
                                            ? FeatherIcons.chevronUp
                                            : FeatherIcons.chevronDown,
                                        size: 14,
                                        color: widget.volts.val >=
                                                widget.voltsList.first.val
                                            ? Theme.of(context).primaryColor
                                            : Colors.red,
                                      ),
                                      Icon(
                                        FeatherIcons.zap,
                                        size: 14,
                                        color: widget.volts.val >=
                                                widget.voltsList.first.val
                                            ? Theme.of(context).primaryColor
                                            : Colors.red,
                                      ),
                                      Text(
                                        '${voltsFormat.format((widget.volts.val - widget.voltsList.first.val).abs())} (${voltsFormat.format((widget.volts.val - widget.voltsList.first.val).abs() / widget.voltsList.first.val * 100)}%)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: widget.volts.val >=
                                                  widget.voltsList.first.val
                                              ? Theme.of(context).primaryColor
                                              : Colors.red,
                                        ),
                                      ),
                                      Text(
                                        widget.index == 0
                                            ? ' Today'
                                            : widget.index == 1
                                                ? ' This Week'
                                                : widget.index == 2
                                                    ? ' This Month'
                                                    : ' All Time',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 25, top: 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${widget.timeFocused.inHours}h ${widget.timeFocused.inMinutes % 60}m',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        ' Focused',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 25),
                              child: Image(
                                image: AssetImage(
                                    'assets/images/logo/Focal Logo_Full Colored.png'),
                                width: 120,
                              ),
                            ),
                          ],
                        ),
                        widget.voltsList == null || widget.voltsList.length <= 1
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: SizedBox(
                                  height: 150,
                                  child: VoltsChart(
                                      data: widget.voltsList, id: 'volts'),
                                ),
                              ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 50,
                            left: 25,
                            right: 25,
                            bottom: 25,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat.yMMMd('en_US')
                                        .format(DateTime.now()),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'https://focal.technology',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  )
                                ],
                              ),
                              Image(
                                image: AssetImage(
                                    'assets/images/qrcode/focaltechnology.png'),
                                width: 69,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
