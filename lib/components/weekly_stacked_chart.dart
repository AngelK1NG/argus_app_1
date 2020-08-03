import 'package:Focal/components/chart_value.dart';
import 'package:Focal/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:Focal/utils/date.dart';

class WeeklyStackedChart extends StatelessWidget {
  final data;
  final colorList;
  final id;
  const WeeklyStackedChart({this.data, this.colorList, this.id, Key key})
      : super(key: key);

  List<charts.Series> createData() {
    List<charts.Series<ChartValue, String>> seriesList = [];
    for (int i = 0; i < data.length; i++) {
      seriesList.add(charts.Series<ChartValue, String>(
        id: this.id,
        data: data[i],
        domainFn: (ChartValue val, _) =>
            DateFormat('EE').format(getDateFromString(val.date)),
        measureFn: (ChartValue val, _) => val.val,
        colorFn: (_, __) => colorList[i],
      ));
    }
    return seriesList;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: charts.BarChart(
        createData(),
        animate: false,
        defaultRenderer: new charts.BarRendererConfig(
          cornerStrategy: const charts.ConstCornerStrategy(20),
        ),
        domainAxis: new charts.OrdinalAxisSpec(
          renderSpec: new charts.SmallTickRendererSpec(
            labelStyle: new charts.TextStyleSpec(
                fontSize: 12, color: charts.ColorUtil.fromDartColor(jetBlack)),
            lineStyle: new charts.LineStyleSpec(
                color: charts.ColorUtil.fromDartColor(
                    Theme.of(context).dividerColor)),
          ),
        ),
        primaryMeasureAxis: new charts.NumericAxisSpec(
          renderSpec: new charts.GridlineRendererSpec(
            labelStyle: new charts.TextStyleSpec(
                fontSize: 12, color: charts.ColorUtil.fromDartColor(jetBlack)),
            lineStyle: new charts.LineStyleSpec(
                color: charts.ColorUtil.fromDartColor(
                    Theme.of(context).dividerColor)),
          ),
        ),
      ),
    );
  }
}
