import 'package:Focal/components/volts.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class VoltsChart extends StatelessWidget {
  final List<Volts> data;
  final String id;
  const VoltsChart({@required this.data, @required this.id, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Volts, DateTime>> series = [
      charts.Series(
        id: this.id,
        data: this.data,
        domainFn: (Volts val, _) => val.dateTime,
        measureFn: (Volts val, _) => val.val,
        colorFn: (_, __) {
          if (data[0].val <= data.last.val) {
            return charts.ColorUtil.fromDartColor(
                Theme.of(context).primaryColor);
          } else {
            return charts.ColorUtil.fromDartColor(Colors.red);
          }
        },
      ),
    ];
    return charts.TimeSeriesChart(
      series,
      animate: false,
      defaultRenderer: new charts.LineRendererConfig(
        smoothLine: true,
      ),
      domainAxis: new charts.DateTimeAxisSpec(
        renderSpec: new charts.NoneRenderSpec(),
      ),
      primaryMeasureAxis: new charts.NumericAxisSpec(
        renderSpec: new charts.NoneRenderSpec(),
        tickProviderSpec:
            new charts.BasicNumericTickProviderSpec(zeroBound: false),
      ),
      layoutConfig: charts.LayoutConfig(
        leftMarginSpec: charts.MarginSpec.fixedPixel(0),
        topMarginSpec: charts.MarginSpec.fixedPixel(0),
        rightMarginSpec: charts.MarginSpec.fixedPixel(0),
        bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
      ),
      behaviors: [
        new charts.SelectNearest(eventTrigger: null),
      ],
    );
  }
}
