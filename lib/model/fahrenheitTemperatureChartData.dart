import 'package:health_parameters_tracker/model/colors.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:health_parameters_tracker/notifier/bill_notifier.dart';

import 'package:intl/intl.dart';

import 'package:charts_flutter/flutter.dart';


class FahrenheitTemperatureChartData extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  //from intl package formatter
  final formatter = new DateFormat.yMMMMd();

  FahrenheitTemperatureChartData(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory FahrenheitTemperatureChartData.withSampleData(HParameterNotifier hParameterNotifier,
      String temperatureDayWeekTypeOfView) {
    //if list of hParameters is empty
    //draw an empty Chart
    if (hParameterNotifier.hParameterList.isEmpty) {
      return new FahrenheitTemperatureChartData(
        _createSampleDataIfEmpty(),
        // Disable animations for image tests.
        animate: true,
      );
    }
    //if list of hParameters is not empty
    //draw chart based on data fetched from firebase (throught notifier)
    else {
      return new FahrenheitTemperatureChartData(
        _createSampleData(hParameterNotifier, temperatureDayWeekTypeOfView),
        // Disable animations for image tests.
        animate: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final celsiusFormatter = new charts.BasicNumericTickFormatterSpec(
        (num value) => '$value \u2109 ');

    return Scaffold(
      body: new charts.TimeSeriesChart(
        seriesList,
        defaultRenderer:
            new charts.LineRendererConfig(includeArea: true, stacked: true),
        animate: animate,
        primaryMeasureAxis: new charts.NumericAxisSpec(
          tickFormatterSpec: celsiusFormatter,
          tickProviderSpec: new charts.StaticNumericTickProviderSpec(
            <charts.TickSpec<num>>[
              charts.TickSpec<num>(93),
              charts.TickSpec<num>(95),
              charts.TickSpec<num>(97),
              charts.TickSpec<num>(99),
              charts.TickSpec<num>(101),
              charts.TickSpec<num>(103),
              charts.TickSpec<num>(105),
              charts.TickSpec<num>(107),
            ],
          ),
        ),
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        behaviors: [
          new charts.SlidingViewport(),
          new charts.ChartTitle('Temperature ',
              behaviorPosition: charts.BehaviorPosition.top,
              titleOutsideJustification: charts.OutsideJustification.middle,
              titleStyleSpec: charts.TextStyleSpec(
                  fontSize: 20,
                  color: charts.ColorUtil.fromDartColor(accentCustomColor)),
              // Set a larger inner padding than the default (10) to avoid
              // rendering the text too close to the top measure axis tick label.
              // The top tick label may extend upwards into the top margin region
              // if it is located at the top of the draw area.
              outerPadding: 20,
              innerPadding: 20),
        ],
      ),
    );
  }

  /// Create one series with data fetched through hParameterNotifier from Firebase.
  static List<charts.Series<TimeSeriesTemperature, DateTime>> _createSampleData(
      HParameterNotifier hParameterNotifier,
      String temperatureDayWeekTypeOfView) {
    var now = new DateTime.now();
    var now_1d = now.subtract(Duration(days: 1));
    var now_1w = now.subtract(Duration(days: 7));
    var now_1m = new DateTime(now.year, now.month - 1, now.day);
    var now_1y = new DateTime(now.year - 1, now.month, now.day);
    var now_1000y = new DateTime(now.year - 1000, now.month, now.day);
    var timePeriod;

    switch (temperatureDayWeekTypeOfView) {
      case 'DAY':
        {
          timePeriod = now_1d;
        }
        break;

      case 'WEEK':
        {
          timePeriod = now_1w;
        }
        break;

      case 'MONTH':
        {
          timePeriod = now_1m;
        }
        break;

      case 'YEAR':
        {
          timePeriod = now_1y;
        }
        break;

      case 'ALL':
        {
          timePeriod = now_1000y;
        }
        break;

      default:
        {
          timePeriod = now_1d;
        }
        break;
    }

    //get data to present the chart
    //loop through all list items where:
    //- in proper "data frame" range
    //- parameter is not empty
    final data = <TimeSeriesTemperature>[
      //loop to get all the items from the hParameterList
      for (int i = 0; i < hParameterNotifier.hParameterList.length; i++)
        //check if it's last day, week or month
        if (timePeriod
            .isBefore(hParameterNotifier.hParameterList[i].createdAt.toDate()) && hParameterNotifier.hParameterList[i].temperatureFahrenheit != null)
          new TimeSeriesTemperature(
              hParameterNotifier.hParameterList[i].createdAt.toDate(),
              double.parse(hParameterNotifier.hParameterList[i].temperatureFahrenheit)),
    ];

    return [
      new charts.Series<TimeSeriesTemperature, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesTemperature temperatureFahrenheit, _) => temperatureFahrenheit.time,
        measureFn: (TimeSeriesTemperature temperatureFahrenheit, _) =>
            temperatureFahrenheit.temperatureFahrenheit,
        data: data,
      )
    ];
  }
}

List<charts.Series<TimeSeriesTemperature, DateTime>>
    _createSampleDataIfEmpty() {
  final data = [
    new TimeSeriesTemperature(new DateTime.now(), 100),
  ];

  return [
    new charts.Series<TimeSeriesTemperature, DateTime>(
      id: 'Temperature',
      colorFn: (_, __) => charts.MaterialPalette.transparent,
      domainFn: (TimeSeriesTemperature temperatureFahrenheit, _) => temperatureFahrenheit.time,
      measureFn: (TimeSeriesTemperature temperatureFahrenheit, _) =>
          temperatureFahrenheit.temperatureFahrenheit,
      data: data,
    )
  ];
}

/// Sample time series data type.
class TimeSeriesTemperature {
  final DateTime time;
  final double temperatureFahrenheit;

  TimeSeriesTemperature(this.time, this.temperatureFahrenheit);
}
