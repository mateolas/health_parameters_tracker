import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:archive_your_bill/notifier/bill_notifier.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  //from intl package formatter
  final formatter = new DateFormat.yMMMMd();
  SimpleTimeSeriesChart(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory SimpleTimeSeriesChart.withSampleData(
      HParameterNotifier hParameterNotifier) {
    //if list of hParameters is empty
    //draw an empty Chart
    if (hParameterNotifier.hParameterList.isEmpty) {
      return new SimpleTimeSeriesChart(
        _createSampleDataIfEmpty(),
        // Disable animations for image tests.
        animate: true,
      );
    }
    //if list of hParameters is not empty
    //draw chart based on data fetched from firebase (throught notifier)
    else {
      return new SimpleTimeSeriesChart(
        _createSampleData(hParameterNotifier),
        // Disable animations for image tests.
        animate: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new charts.TimeSeriesChart(
        seriesList,
        animate: animate,

        // Optionally pass in a [DateTimeFactory] used by the chart. The factory
        // should create the same type of [DateTime] as the data provided. If none
        // specified, the default creates local date time.
        dateTimeFactory: const charts.LocalDateTimeFactory(),

        // domainAxis: charts.DateTimeAxisSpec(
        //   tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
        //     // year: charts.TimeFormatterSpec(
        //     //   format: 'dd HH:mm',
        //     //   transitionFormat: '''dd/MM
        //     //   HH:mm''',
        //     // ),
        //     month: charts.TimeFormatterSpec(
        //       format: 'dd/MM HH:mm',
        //       transitionFormat: 'dd/MM HH:mm',
        //     ),
        //     day: charts.TimeFormatterSpec(
        //       format: '''dd/MM HH:mm''',
        //       transitionFormat: '''dd/MM HH:mm''',
        //     ),
        //     hour: charts.TimeFormatterSpec(
        //       format: ''''dd 
        //       HH:mm''',
        //       transitionFormat: 'HH',
        //     ),
        //     minute: charts.TimeFormatterSpec(
        //       format: '''dd/MM
        //       HH:mm''',
        //       transitionFormat: 'mm',
        //     ),
        //   ),
        // ),
        behaviors: [
          new charts.SlidingViewport(),
          new charts.PanAndZoomBehavior(),
          //setting the title of the chart
          new charts.ChartTitle('Temperature',
              behaviorPosition: charts.BehaviorPosition.top,
              titleOutsideJustification: charts.OutsideJustification.middle,
              titleStyleSpec: charts.TextStyleSpec(fontSize: 14),
              // Set a larger inner padding than the default (10) to avoid
              // rendering the text too close to the top measure axis tick label.
              // The top tick label may extend upwards into the top margin region
              // if it is located at the top of the draw area.
              innerPadding: 12),
        ],
      ),
    );
  }

  /// Create one series with data fetched through hParameterNotifier from Firebase.
  static List<charts.Series<TimeSeriesTemperature, DateTime>> _createSampleData(
      HParameterNotifier hParameterNotifier) {
    var now = new DateTime.now();
    var now_1d = now.subtract(Duration(days: 1));
    var now_1w = now.subtract(Duration(days: 7));
    var now_1m = new DateTime(now.year, now.month - 1, now.day);
    var now_1y = new DateTime(now.year - 1, now.month, now.day);

    
    final data = <TimeSeriesTemperature>[
      //loop to get all the items from the hParameterList
      for (int i = 0; i < hParameterNotifier.hParameterList.length; i++)
        //check if it's last day, week or month
        if (now_1w
            .isBefore(hParameterNotifier.hParameterList[i].createdAt.toDate()))
          new TimeSeriesTemperature(
              hParameterNotifier.hParameterList[i].createdAt.toDate(),
              int.parse(hParameterNotifier.hParameterList[i].temperature)),
    ];

    return [
      new charts.Series<TimeSeriesTemperature, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesTemperature temperature, _) => temperature.time,
        measureFn: (TimeSeriesTemperature temperature, _) =>
            temperature.temperature,
        data: data,
      )
    ];
  }
}

List<charts.Series<TimeSeriesTemperature, DateTime>>
    _createSampleDataIfEmpty() {
  final data = [
    new TimeSeriesTemperature(new DateTime(2017, 9, 19), 1),
  ];

  return [
    new charts.Series<TimeSeriesTemperature, DateTime>(
      id: 'Temperature',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TimeSeriesTemperature sales, _) => sales.time,
      measureFn: (TimeSeriesTemperature sales, _) => sales.temperature,
      data: data,
    )
  ];
}

/// Sample time series data type.
class TimeSeriesTemperature {
  final DateTime time;
  final int temperature;

  TimeSeriesTemperature(this.time, this.temperature);
}
