import 'package:Focal/components/chart_value.dart';
import 'package:Focal/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:Focal/utils/date.dart';

class WeeklyChart extends StatelessWidget {
  final List<ChartValue> data;
  final barColor;
  final id;
  const WeeklyChart({this.data, this.barColor, this.id, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<ChartValue, String>> series = [
      charts.Series(
        id: this.id,
        data: this.data,
        domainFn: (ChartValue val, _) =>
            DateFormat('EE').format(getDateFromString(val.date)),
        measureFn: (ChartValue val, _) => val.val,
        colorFn: (_, __) => barColor,
      ),
    ];
    return SizedBox(
      child: charts.BarChart(
        series,
        animate: false,
        defaultRenderer: new charts.BarRendererConfig(
          cornerStrategy: const charts.ConstCornerStrategy(20),
        ),
        domainAxis: new charts.OrdinalAxisSpec(
          renderSpec: new charts.SmallTickRendererSpec(
            labelStyle: new charts.TextStyleSpec(
              fontSize: 12,
              color: charts.ColorUtil.fromDartColor(jetBlack)
            ),
            lineStyle: new charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(Theme.of(context).dividerColor)
            ),
          ),
        ),
        primaryMeasureAxis: new charts.NumericAxisSpec(
          renderSpec: new charts.GridlineRendererSpec(
            labelStyle: new charts.TextStyleSpec(
              fontSize: 12,
              color: charts.ColorUtil.fromDartColor(jetBlack)
            ),
            lineStyle: new charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(Theme.of(context).dividerColor)
            ),
          ),
        ),
      ),
    );
  }
}
