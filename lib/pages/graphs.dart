import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphsPage extends StatelessWidget {
  
  GraphsPage({super.key});

  LocalDatabase db = LocalDatabase();

  DateTime today = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  List getCalorieDataForPastWeek() {

    int modifier = 7;
    List data = [];

    for(var i = 0 ; i < 7; i++) {
      DateTime date = today.subtract(Duration(days: modifier));


      Map nutrientsForDay = db.calcNutrientsConsumedForDay(date.toString());
      int caloriesForDay = nutrientsForDay['caloriesConsumed'] - nutrientsForDay['caloriesBurned'];

      int goalCaloriesForDay = db.getPreferences(date.toString())['calories'];

      data.add([caloriesForDay, goalCaloriesForDay, date.weekday]);

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

  List<BarChartGroupData> getBars() {

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Graphs')),
        backgroundColor: Colors.black,
      ),
      body: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text('Calories')
            ),
            topTitles: AxisTitles(
              axisNameWidget: Text('Calorie delta for past week')
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: switch(value) {
                      0 => Text('Mo'),
                      1 => Text('Tu'),
                      2 => Text('We'),
                      3 => Text('Th'),
                      4 => Text('Fr'),
                      5 => Text('Sa'),
                      _ => Text('Su')
                    }
                  );
                }
              )
            )
          ),
          barGroups: getBars()
        ),

      ),
    );
  }
}
