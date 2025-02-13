import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class DailyStats extends StatefulWidget {

  String selectedDate;

  DailyStats({
    super.key,
    required this.selectedDate
  });

  @override
  State<DailyStats> createState() => _DailyStatsState();
}

class _DailyStatsState extends State<DailyStats> {

  LocalDatabase db = LocalDatabase();

  int caloriesConsumed = 0;
  int caloriesBurned = 0;
  int proteinConsumed = 0;
  int carbsConsumed = 0;
  int fatConsumed = 0;

  @override
  void initState() {
    Map nutrients = db.calcNutrientsConsumedForDay(widget.selectedDate);
    caloriesConsumed = nutrients['caloriesConsumed'];
    caloriesBurned = nutrients['caloriesBurned'];
    proteinConsumed = nutrients['proteinConsumed'];
    carbsConsumed = nutrients['carbsConsumed'];
    fatConsumed = nutrients['fatConsumed'];
    super.initState();
  }

  // if parent updates (food, exercise deleted / date change), recalc
  @override
  void didUpdateWidget(DailyStats oldWidget) {
    super.didUpdateWidget(oldWidget);
    Map nutrients = db.calcNutrientsConsumedForDay(widget.selectedDate);
    caloriesConsumed = nutrients['caloriesConsumed'];
    caloriesBurned = nutrients['caloriesBurned'];
    proteinConsumed = nutrients['proteinConsumed'];
    carbsConsumed = nutrients['carbsConsumed'];
    fatConsumed = nutrients['fatConsumed'];
  }

  List calcNutrientDelta(int nutrientConsumedToday, String nutrient) {
    double percentageFilled =
    (nutrientConsumedToday / (db.getPreferences(widget.selectedDate)[nutrient]));

    if (percentageFilled.isInfinite) {
      percentageFilled = 100;
    } else if (percentageFilled.isNaN) {
      percentageFilled = 0;
    }

    if (percentageFilled < 0.8 || percentageFilled > 1.1) {
      return [percentageFilled, Colors.red];
    }
    return [percentageFilled, Colors.green];
  }

  Widget macroProgressIndicator (int macroConsumedToday, String macro) {
    return Row(
      children: [
        SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(
            value: calcNutrientDelta(macroConsumedToday, macro)[0],
            color: calcNutrientDelta(macroConsumedToday, macro)[1],
            backgroundColor: Colors.grey[800],
          ),
        ),
        Text('  ${macro.toUpperCase().substring(0,1)}: ${macroConsumedToday} /'
            '${db.getPreferences(widget.selectedDate)[macro].toString()}'
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(),
          height: 80.0,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: LinearProgressIndicator(
                  //Here you pass the percentage
                  value: calcNutrientDelta(
                      caloriesConsumed - caloriesBurned, 'calories')[0],
                  color: calcNutrientDelta(
                      caloriesConsumed - caloriesBurned, 'calories')[1],
                  backgroundColor: Colors.blue.withAlpha(50),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text('${caloriesConsumed} '
                    '(-${caloriesBurned}) / '
                    '${db.getPreferences(widget.selectedDate)['calories']} '
                    'Calories'),
              )
            ],
          ),
        ),

        Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                macroProgressIndicator(proteinConsumed, 'protein'),
                macroProgressIndicator(carbsConsumed, 'carbs'),
                macroProgressIndicator(fatConsumed, 'fat')
              ],
            ),
          ),
        ),
      ],
    );
  }
}
