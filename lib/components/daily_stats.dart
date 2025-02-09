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

  int caloriesConsumedToday = 0;
  int caloriesBurnedToday = 0;
  int proteinConsumedToday = 0;
  int carbsConsumedToday = 0;
  int fatConsumedToday = 0;

  @override
  void initState() {
    calcNutrientsConsumedToday();
    super.initState();
  }

  // if parent updates (food, exercise deleted / date change), recalc
  @override
  void didUpdateWidget(DailyStats oldWidget) {
    super.didUpdateWidget(oldWidget);
    calcNutrientsConsumedToday();
  }

  void calcNutrientsConsumedToday() {

    int caloriesConsumed = 0;
    int caloriesBurned = 0;
    int proteinConsumed = 0;
    int carbsConsumed = 0;
    int fatConsumed = 0;

    var times = ['Morning', 'Afternoon', 'Evening'];

    for (var time in times) {
      var foodList = db.getFoodEntriesForDate(widget.selectedDate)[time] ?? [];
      for (var food in foodList) {
        caloriesConsumed +=
            (food.nutriments!.getComputedKJ(PerSize.oneHundredGrams) ?? 0 *
                (int.parse(food.quantity!) / 100)).toInt();
        proteinConsumed +=
            (food.nutriments!.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0 *
                (int.parse(food.quantity!) / 100)).toInt();
        carbsConsumed +=
            (food.nutriments!.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ?? 0 *
                (int.parse(food.quantity!) / 100)).toInt();
        fatConsumed +=
            (food.nutriments!.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0 *
                (int.parse(food.quantity!) / 100)).toInt();
      }
    }
    var exerciseList = db.getExerciseEntriesForDate(widget.selectedDate);
    for (var exercise in exerciseList) {
      caloriesBurned += exercise.calBurned;
    }

    setState(() {
      caloriesConsumedToday = caloriesConsumed;
      caloriesBurnedToday = caloriesBurned;
      proteinConsumedToday = proteinConsumed;
      carbsConsumedToday = carbsConsumed;
      fatConsumedToday = fatConsumed;
    });
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
                      caloriesConsumedToday - caloriesBurnedToday, 'calories')[0],
                  color: calcNutrientDelta(
                      caloriesConsumedToday - caloriesBurnedToday, 'calories')[1],
                  backgroundColor: Colors.blue.withAlpha(50),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text('${caloriesConsumedToday} '
                    '(-${caloriesBurnedToday}) / '
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
                macroProgressIndicator(proteinConsumedToday, 'protein'),
                macroProgressIndicator(carbsConsumedToday, 'carbs'),
                macroProgressIndicator(fatConsumedToday, 'fat')
              ],
            ),
          ),
        ),
      ],
    );
  }
}
