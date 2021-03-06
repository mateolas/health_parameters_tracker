import 'package:flutter/material.dart';
import 'package:health_parameters_tracker/api/hParameter_api.dart';
import 'package:health_parameters_tracker/model/colors.dart';

import 'package:health_parameters_tracker/notifier/bill_notifier.dart';
import 'package:health_parameters_tracker/notifier/units_notifier.dart';
import 'package:provider/provider.dart';

import 'package:health_parameters_tracker/model/celsiusTemperatureChartData.dart';
import 'package:health_parameters_tracker/model/fahrenheitTemperatureChartData.dart';
import 'package:health_parameters_tracker/model/kilogramsWeightChartData.dart';
import 'package:health_parameters_tracker/model/poundsWeightChartData.dart';
import 'package:health_parameters_tracker/model/saturationChartData.dart';
import 'package:health_parameters_tracker/model/pulseChartData.dart';
import 'package:health_parameters_tracker/widgets/temperatureSetOfButtons.dart';
import 'package:health_parameters_tracker/widgets/FahrenheittemperatureSetOfButtons.dart';
import 'package:health_parameters_tracker/widgets/saturationSetOfButtons.dart';
import 'package:health_parameters_tracker/widgets/weightSetOfButtons.dart';
import 'package:health_parameters_tracker/widgets/poundsWeightSetOfButtons.dart';
import 'package:health_parameters_tracker/widgets/pulseSetOfButtons.dart';

import 'package:flutter/rendering.dart';

class MainGeneralChart extends StatefulWidget {
  MainGeneralChart();

  @override
  _MainGeneralChartState createState() => _MainGeneralChartState();
}

class _MainGeneralChartState extends State<MainGeneralChart>
    with SingleTickerProviderStateMixin {
  //what temperature time frame was selected: Day/Week/Month/Year/All
  String selectedTimeTempView;
  String selectedTypeOfCharts;
  //determine the "roundness" of tab bars
  var radius = Radius.circular(32);

  //Name of time frames to present for TabBar
  List timeTempView = [
    'DAY',
    'WEEK',
    'MONTH',
    'YEAR',
    'ALL',
  ];

//Controller for time frame tab (day, week, month etc.)
  TabController _timeTempTimeViewController;

//Name of type of charts (Temp, Pulse etc.) to present for TabBar
  List typesOfCharts = [
    'TEMPERATURE',
    'PULSE',
    'SATURATION',
    'WEIGHT',
  ];

  //Controller for types of chart
  TabController _typeOfChartController;
  int tabIndex = 0;

  //calling initState function to initialize _currentHparameter
  @override
  void initState() {
    super.initState();
    HParameterNotifier hParameterNotifier =
        Provider.of<HParameterNotifier>(context, listen: false);

    //fetching data from firebase
    getHParameters(hParameterNotifier);
    //setting default temperature time frame view for 'Day'
    selectedTimeTempView = 'Day';
    _typeOfChartController = new TabController(vsync: this, length: 4);
  }

  Widget whatTypeOfChartToPresent(
      HParameterNotifier hParameterNotifier,
      UnitsNotifier unitsNotifier,
      String typesOfCharts,
      String selectedTimeTempView) {
    switch (typesOfCharts) {
      case 'TEMPERATURE':
        {
          if (unitsNotifier.getIsCelsius == true) {
            return CelsiusTemperatureChartData.withSampleData(
                hParameterNotifier, selectedTimeTempView);
          } else {
            return FahrenheitTemperatureChartData.withSampleData(
                hParameterNotifier, selectedTimeTempView);
          }
        }
        break;

      case 'PULSE':
        {
          return PressureChartData.withSampleData(
              hParameterNotifier, selectedTimeTempView);
        }
        break;

      case 'SATURATION':
        {
          return SaturationChartData.withSampleData(
              hParameterNotifier, selectedTimeTempView);
        }
        break;

      case 'WEIGHT':
        {
          if (unitsNotifier.getIsKilogram == true) {
            return KilogramsWeightChartData.withSampleData(
                hParameterNotifier, selectedTimeTempView);
          } else {
            return PoundsWeightChartData.withSampleData(
                hParameterNotifier, selectedTimeTempView);
          }
        }
        break;

      default:
        {
          if (unitsNotifier.getIsCelsius == true) {
            return CelsiusTemperatureChartData.withSampleData(
                hParameterNotifier, selectedTimeTempView);
          } else {
            return FahrenheitTemperatureChartData.withSampleData(
                hParameterNotifier, selectedTimeTempView);
          }
        }
        break;
    }
  }

  Widget whatTypeOfButtonsToPresent(
      String typesOfCharts, UnitsNotifier unitsNotifier) {
    switch (typesOfCharts) {
      case 'TEMPERATURE':
        {
          if (unitsNotifier.getIsCelsius == true) {
            return TemperatureSetOfButtons();
          } else {
            return FahrenheitTemperatureSetOfButtons();
          }
        }
        break;

      case 'PULSE':
        {
          return PulseSetOfButtons();
        }
        break;

      case 'SATURATION':
        {
          return SaturationSetOfButtons();
        }
        break;

      case 'WEIGHT':
        {
          if (unitsNotifier.getIsKilogram == true) {
            return WeightSetOfButtons();
          } else {
            return PoundsWeightSetOfButtons();
          }
        }
        break;

      default:
        {
          if (unitsNotifier.getIsCelsius == true) {
            return TemperatureSetOfButtons();
          } else {
            return FahrenheitTemperatureSetOfButtons();
          }
        }
        break;
    }
  }

  setTabColor(int tabIndex) {
    if (tabIndex == 0) {
      return accentCustomColor;
    } else if (tabIndex == 1) {
      return Colors.red;
    } else if (tabIndex == 2) {
      return Colors.blue;
    } else if (tabIndex == 3) {
      return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    HParameterNotifier hParameterNotifier =
        Provider.of<HParameterNotifier>(context, listen: true);
    UnitsNotifier unitsNotifier =
        Provider.of<UnitsNotifier>(context, listen: true);
    return Column(
      children: [
        Padding(
          padding: new EdgeInsets.fromLTRB(6, 0, 0, 6),
          child: SizedBox(
              //size of the chart
              height: MediaQuery.of(context).size.height / 2.4,
              //prints chart
              child: whatTypeOfChartToPresent(hParameterNotifier, unitsNotifier,
                  selectedTypeOfCharts, selectedTimeTempView)),
        ),

        /// tab controller for time frame ///
        DefaultTabController(
          length: timeTempView.length,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 34),
            child: TabBar(
              onTap: (index) {
                setState(() {
                  //set the name of temperature time frame
                  //selectedTimeTempView used as an argument in "draw a chart" function
                  selectedTimeTempView = timeTempView[index];
                });
              },
              indicatorColor: setTabColor(tabIndex),

              controller: _timeTempTimeViewController,
              isScrollable: true,
              labelStyle: TextStyle(
                fontSize: 12.0,
              ),
              //For Selected tab
              unselectedLabelStyle: TextStyle(
                fontSize: 12.0,
              ), //For Un-selected Tabs
              //funtion to generate tabs
              tabs: new List.generate(timeTempView.length, (index) {
                return new Tab(
                  iconMargin: EdgeInsets.only(bottom: 3),
                  text: timeTempView[index].toUpperCase(),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 4),

        /// tab controller for type of chart (Temperature, pressure, etc.) ///
        DefaultTabController(
          length: typesOfCharts.length,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
            child: Container(
              height: 32,
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                onTap: (index) {
                  setState(() {
                    //set the name of type of the chart
                    //selectedTypeOfCharts used as an argument in switch function
                    selectedTypeOfCharts = typesOfCharts[index];
                    tabIndex = index;
                  });
                },
                indicator: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    topRight: radius,
                    topLeft: radius,
                    bottomRight: radius,
                    bottomLeft: radius,
                  )),
                  color: setTabColor(tabIndex),
                ),
                controller: _typeOfChartController,
                isScrollable: true,
                //For Selected tab
                labelStyle: TextStyle(fontSize: 14.0, color: Colors.white),
                //For Un-selected Tabs
                unselectedLabelStyle:
                    TextStyle(fontSize: 12.0, color: Colors.green),
                //funtion to generate tabs
                tabs: new List.generate(typesOfCharts.length, (index) {
                  return new Tab(
                    iconMargin: EdgeInsets.only(bottom: 3),
                    text: typesOfCharts[index].toUpperCase(),
                  );
                }),
              ),
            ),
          ),
        ),
        SizedBox(height: 44),
        //Row for buttons
        whatTypeOfButtonsToPresent(selectedTypeOfCharts, unitsNotifier),
        SizedBox(height: 40),
      ],
    );
  }
}
