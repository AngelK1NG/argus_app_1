import 'package:Focal/components/chart_value.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:Focal/utils/date.dart';

class weeklyChart extends StatelessWidget {
  final List<chartValue> data;
  final barColor;
  const weeklyChart({this.data, this.barColor});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<chartValue, String>> series = [
      charts.Series(
        id: 'Total Distractions',
        data: this.data,
        domainFn: (chartValue val, _) =>
            DateFormat('EE').format(getDateFromString(val.date)),
        measureFn: (chartValue val, _) => val.val,
        colorFn: (_, __) => barColor,
      ),
    ];
    return Container(
      child: charts.BarChart(
        series,
        animate: true,
      ),
    );
  }
}
