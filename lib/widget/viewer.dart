import 'package:flutter/material.dart';
import 'package:opendata/api/api.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:opendata/widget/labeled_switch.dart';

class GraphViewer extends StatefulWidget {
  final ApiInterface api;
  ApiResult apiResult;

  GraphViewer({Key? key, required this.api, required this.apiResult})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _GraphViewerState(apiResult);


}

class _GraphViewerState extends State<GraphViewer> {
  ApiResult apiResult;

  _GraphViewerState(this.apiResult);

  bool daytime = false;
  bool stacked = false;
  String chartType = "line";

  @override
  void initState() {
    daytime = widget.api.defaultParameterDaytime;
    stacked = widget.api.defaultParameterStacked;
    chartType = widget.api.defaultParameterChartType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (apiResult.count < apiResult.maxCount) {
      widget.api.next(old: apiResult).then((value) {
        setState(() {
          apiResult = value;
        });
      });
    }

    return Column(
      children: [
        Expanded(child: chart(apiResult)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.api.hasStacked && chartType == "line")
              LabeledSwitch(
                value: stacked,
                onChanged: (nValue) => setState(() {
                  stacked = nValue;
                }),
                label: Text("Stacked "),
              ),
            if (widget.api.hasLineChart && widget.api.hasBarChart)
              LabeledSwitch(
                value: chartType == "bar",
                onChanged: (nValue) => setState(() {
                  if (nValue) {
                    chartType = "bar";
                  } else {
                    chartType = "line";
                  }
                }),
                label: Text("Line / Bar "),
              ),
            for (var param in widget.api.parameters)
              if (param.value is bool)
                LabeledSwitch(
                  value: param.value,
                  onChanged: (nValue) {
                    setState(() {
                      param.value = nValue;
                    });
                  },
                  label: Text(param.label),
                )
          ],
        ),
        Expanded(
          child: Text(""),
        ),
      ],
    );
  }

  charts.NumericAxisSpec numericAxis = charts.NumericAxisSpec(
    renderSpec: charts.SmallTickRendererSpec(
      labelStyle: charts.TextStyleSpec(
        fontSize: 14,
        color: charts.MaterialPalette.white,
      ),
    ),
  );

  Widget chart(ApiResult res) {
    if (chartType == "line" && daytime == false) {
      return charts.LineChart(
        res.lineChartData(stacked: stacked, daytime: false, parameters: widget.api.parameters),
        domainAxis: charts.NumericAxisSpec(
          viewport: res.numericExtents,
          renderSpec: charts.SmallTickRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 14,
              color: charts.MaterialPalette.white,
            ),
          ),
        ),
        primaryMeasureAxis: numericAxis,
        defaultRenderer: charts.LineRendererConfig(
          includeArea: true,
          stacked: stacked,
        ),
        animate: false,
        behaviors: [charts.SeriesLegend(showMeasures: true)],
      );
    } else if (chartType == "line" && daytime == true) {
      return charts.TimeSeriesChart(
        res.lineChartData(stacked: stacked, daytime: true,  parameters: widget.api.parameters),
        defaultRenderer: charts.LineRendererConfig(
          includeArea: true,
          stacked: stacked,
        ),
        domainAxis: charts.DateTimeAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 14,
              color: charts.MaterialPalette.white,
            ),
          ),
          tickProviderSpec: charts.DayTickProviderSpec(increments: [365]),
        ),
        primaryMeasureAxis: numericAxis,
        animate: false,
        behaviors: [
          charts.SeriesLegend(showMeasures: true),
        ],
      );
    } else if (chartType == "bar" && daytime == false) {
      return charts.BarChart(
        res.barChartData(stacked: stacked, daytime: daytime, parameters: widget.api.parameters),
        domainAxis: numericAxis,
        primaryMeasureAxis: numericAxis,
        behaviors: [
          charts.SeriesLegend(showMeasures: true),
        ],
      );
    } else if (chartType == "bar" && daytime == true) {
      return charts.TimeSeriesChart(
        res.barChartData(stacked: stacked, daytime: daytime, parameters: widget.api.parameters),
        domainAxis: charts.DateTimeAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 14,
              color: charts.MaterialPalette.white,
            ),
          ),
          tickProviderSpec: charts.DayTickProviderSpec(increments: [365]),
        ),
        primaryMeasureAxis: numericAxis,
        defaultRenderer: charts.BarRendererConfig<DateTime>(),
        behaviors: [
          charts.SeriesLegend(showMeasures: true),
        ],
      );
    }
    throw UnimplementedError();
  }
}