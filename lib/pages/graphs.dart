import 'package:caloreasy/components/date_selector.dart';
import 'package:caloreasy/components/two_tab_selector.dart';
import 'package:caloreasy/components/weight_dialog.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphsPage extends StatefulWidget {
  
  GraphsPage({super.key});

  @override
  State<GraphsPage> createState() => _GraphsPageState();
}

class _GraphsPageState extends State<GraphsPage> {

  bool firstTabSelected = true;

  LocalDatabase db = LocalDatabase();

  DateTime selectedDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  List getCalorieDataForPastWeek() {

    int modifier = 6;
    List data = [];

    for(var i = 0 ; i < 7; i++) {
      DateTime date = selectedDate.subtract(Duration(days: modifier));

      Map nutrientsForDay = db.calcNutrientsConsumedForDay(date.toString());
      int caloriesForDay = nutrientsForDay['caloriesConsumed'] - nutrientsForDay['caloriesBurned'];

      int goalCaloriesForDay = db.getPreferences(date.toString())['calories'];

      data.add([caloriesForDay, goalCaloriesForDay, date.weekday]);

      modifier--;
    }

    return data;
  }

  List getWeightDataForPastWeek() {

    int modifier = 6;
    List data = [];

    for(var i = 0 ; i < 7; i++) {
      DateTime date = selectedDate.subtract(Duration(days: modifier));

      data.add([db.getWeightForDate(date.toString()), date.weekday]);
      modifier--;
    }
    return data;
  }

  Color getBarColor(int caloriesConsumed, int goalCalories) {
    double percentageFilled =
    (caloriesConsumed / goalCalories);

    if (percentageFilled.isInfinite) {
      percentageFilled = 2;
    } else if (percentageFilled.isNaN) {
      percentageFilled = 0;
    }

    if (percentageFilled < 0.8 || percentageFilled > 1.1) {
      return Colors.red;
    }
    return Colors.green;
  }

  List<BarChartGroupData> getCalorieGraphBars() {

    List<BarChartGroupData> data = [];

    List calorieData = getCalorieDataForPastWeek();

    for(int i = 0 ; i < 7; i++) {
      data.add(
        BarChartGroupData(
          x: calorieData[i][2],
          barRods: [
            // consumed
            BarChartRodData(
                toY: calorieData[i][0].toDouble(),
                color: getBarColor(calorieData[i][0], calorieData[i][1])
            ),
            // goal
            BarChartRodData(toY: calorieData[i][1].toDouble()),
          ]
        )
      );
    }
    return data;
  }

  List<FlSpot> getWeightGraphPoints() {
    List<FlSpot> data = [];

    List weightData = getWeightDataForPastWeek();
    for (int i = 0; i < 7; i++) {
      data.add(FlSpot(i.toDouble(), weightData[i][0]));
    }
    return data;
  }

  void updateDate(String direction) {
    setState(() {
      direction == 'forward' ? selectedDate = selectedDate.add(Duration(days: 1)) :
      selectedDate = selectedDate.subtract(Duration(days: 1));
    });
  }

  Widget calorieDeltaGraph() {
    return BarChart(
      BarChartData(
          titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                  axisNameWidget: Text('Calories')
              ),
              topTitles: AxisTitles(
                  axisNameWidget: null
              ),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                            meta: meta,
                            child: switch(value) {
                              0 => Text('Su'),
                              1 => Text('Mo'),
                              2 => Text('Tu'),
                              3 => Text('We'),
                              4 => Text('Th'),
                              5 => Text('Fr'),
                              _ => Text('Sa')
                            }
                        );
                      }
                  )
              )
          ),
          barGroups: getCalorieGraphBars()
      ),
    );
  }

  Widget weightGraph() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                axisNameWidget: Text('Weight in KG')
            ),
            topTitles: AxisTitles(
                axisNameWidget: null
            ),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      var mostRecentDataPointOffset = getWeightDataForPastWeek().last[1];
                      value = value + mostRecentDataPointOffset + 1;
                      return SideTitleWidget(
                          meta: meta,
                          child: switch(value) {
                            0 => Text('Su'),
                            1 => Text('Mo'),
                            2 => Text('Tu'),
                            3 => Text('We'),
                            4 => Text('Th'),
                            5 => Text('Fr'),
                            6 => Text('Sa'),
                            7 => Text('Su'),
                            8 => Text('Mo'),
                            9 => Text('Tu'),
                            10 => Text('We'),
                            11 => Text('Th'),
                            12 => Text('Fr'),
                            13 => Text('Sa'),
                            _ => Text('Su')
                          }
                      );
                    }
                )
            )
        ),
        lineBarsData: [
          LineChartBarData(
            spots: getWeightGraphPoints(),
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Graphs')),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: !firstTabSelected ?
        FloatingActionButton(
          shape: ContinuousRectangleBorder(),
          onPressed: () async {
            await showDialog(context: context, builder: (context) {
              return WeightDialog(selectedDate: selectedDate);
            });
            setState(() {});
          },
          child: Icon(Icons.add),
        ) : null,
      body: Column(
        children: [

          Divider(height: 1, thickness: 1, color: Colors.grey[800],),

          DateSelector(selectedDate: selectedDate, updateDate: updateDate),

          Divider(height: 1, thickness: 1, color: Colors.grey[800],),

          TwoTabSelector(
              firstTabSelected: firstTabSelected,
              updateTabSelection: (updatedSelection) => setState(() {firstTabSelected = updatedSelection;}),
              tabNames: ['Calorie Delta', 'Weight'],
              icons: [Icon(Icons.food_bank), Icon(Icons.monitor_weight)]
          ),

          firstTabSelected ?
            Expanded(child: calorieDeltaGraph())
            : Expanded(child: weightGraph())
        ],
      ),
    );
  }
}
