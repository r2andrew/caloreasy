import 'package:caloreasy/components/grouped_foods.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:caloreasy/pages/add_food.dart';
import 'package:caloreasy/pages/preferences.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'add_exercise.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {

  DateTime selectedDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  DateTime todaysDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  LocalDatabase db = LocalDatabase();

  bool exercisesView = false;

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

  void calcNutrientsConsumedToday() {

    int caloriesConsumed = 0;
    int caloriesBurned = 0;
    int proteinConsumed = 0;
    int carbsConsumed = 0;
    int fatConsumed = 0;

    var times = ['Morning', 'Afternoon', 'Evening'];

    for (var time in times) {
      var foodList = db.getFoodEntriesForDate(selectedDate.toString())[time] ?? [];
      for (var food in foodList) {
        caloriesConsumed +=
            (food.nutriments!.getComputedKJ(PerSize.oneHundredGrams)! *
            (int.parse(food.quantity!) / 100)).toInt();
        proteinConsumed +=
            (food.nutriments!.getValue(Nutrient.proteins, PerSize.oneHundredGrams)! *
            (int.parse(food.quantity!) / 100)).toInt();
        carbsConsumed +=
            (food.nutriments!.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams)! *
                (int.parse(food.quantity!) / 100)).toInt();
        fatConsumed +=
            (food.nutriments!.getValue(Nutrient.fat, PerSize.oneHundredGrams)! *
                (int.parse(food.quantity!) / 100)).toInt();
      }
    }
    var exerciseList = db.getExerciseEntriesForDate(selectedDate.toString());
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
    (nutrientConsumedToday / (db.getPreferences(selectedDate.toString())[nutrient]));

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

  void changeSelectedDate(String direction) {
    setState(() {
      if (direction == "forward") {
        selectedDate = selectedDate.add(Duration(days: 1));
      } else {
        selectedDate = selectedDate.subtract(Duration(days: 1));
      }
      calcNutrientsConsumedToday();
    });
  }

  void deleteFood (id) {
    setState(() {
      db.deleteFoodEntry(selectedDate.toString(), id);
      calcNutrientsConsumedToday();
    });
  }
  
  void deleteExercise(index) {
    setState(() {
      db.deleteExerciseEntry(selectedDate.toString(), index);
    });
  }

  // separate to widget to conditionally show functions only
  // if selected date today
  Widget _FloatingActionButtons () {
    if (selectedDate != todaysDate) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            FloatingActionButton(
              heroTag: 'Preferences',
              backgroundColor: Colors.white,
              onPressed: () => {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PreferencesPage(selectedDate: selectedDate.toString(),)
                  // rebuild widget on return from adding
                )).then((_) => setState(() {}))
              },
              child: Icon(Icons.edit, color: Colors.black,),
            ),

            FloatingActionButton(
              heroTag: 'Exercise',
              backgroundColor: Colors.white,
              onPressed: () => {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AddExercisePage(selectedDate: selectedDate.toString(),)
                  // rebuild widget on return from adding
                )).then((_) => setState(() {calcNutrientsConsumedToday();}))
              },
              child: Icon(Icons.run_circle, color: Colors.black,),
            ),

            FloatingActionButton(
              heroTag: 'Add',
              backgroundColor: Colors.white,
              onPressed: () => {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AddFoodPage(selectedDate: selectedDate.toString())
                  // rebuild widget on return from adding
                )).then((_) => setState(() {calcNutrientsConsumedToday();}))
              },
              child: Icon(Icons.food_bank, color: Colors.black,),
            )

          ],
        ),
      );
    }
  }

  Widget DateSelector () {
    // only display forward option if selectedDate is before todaysDate
    // (can't select future dates)
    if (selectedDate.isBefore(todaysDate)) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.grey[800],
              onPressed: () => changeSelectedDate("back"),
              child: Text('Back'),
            ),
            Text('${selectedDate.day}-${selectedDate.month}-${selectedDate
                .year}'),
            MaterialButton(
              color: Colors.grey[800],
              onPressed: () => changeSelectedDate("forward"),
              child: Text('Forward'),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.grey[800],
              onPressed: () => changeSelectedDate("back"),
              child: Text('Back'),
            ),
            Text('${selectedDate.day}-${selectedDate.month}-${selectedDate
                .year}'),
            SizedBox(width: 80, height: 20)
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Tracker')),
        backgroundColor: Colors.black,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _FloatingActionButtons(),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              height: 80.0,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned.fill(
                    child: LinearProgressIndicator(
                      //Here you pass the percentage
                      value: calcNutrientDelta(caloriesConsumedToday - caloriesBurnedToday, 'calories')[0],
                      color: calcNutrientDelta(caloriesConsumedToday - caloriesBurnedToday, 'calories')[1],
                      backgroundColor: Colors.blue.withAlpha(50),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('${caloriesConsumedToday} (-${caloriesBurnedToday}) / ${db.getPreferences(selectedDate.toString())['calories']} Calories'),
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      value: calcNutrientDelta(proteinConsumedToday, 'protein')[0],
                      color: calcNutrientDelta(proteinConsumedToday, 'protein')[1],
                      backgroundColor: Colors.grey[800],
                    ),
                  ),
                  Text('P: ${proteinConsumedToday} /'
                      '${db.getPreferences(selectedDate.toString())['calories'].toString()}'
                  ),

                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      value: calcNutrientDelta(carbsConsumedToday, 'carbs')[0],
                      color: calcNutrientDelta(carbsConsumedToday, 'carbs')[1],
                      backgroundColor: Colors.grey[800],
                    ),
                  ),
                  Text('C: ${carbsConsumedToday} /'
                      '${db.getPreferences(selectedDate.toString())['carbs'].toString()}'
                  ),

                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      value: calcNutrientDelta(fatConsumedToday, 'fat')[0],
                      color: calcNutrientDelta(fatConsumedToday, 'fat')[1],
                      backgroundColor: Colors.grey[800],
                    ),
                  ),
                  Text('F: ${fatConsumedToday} /'
                      '${db.getPreferences(selectedDate.toString())['fat'].toString()}'
                  )
                ],
              ),
            ),

            DateSelector(),

            ExpandablePanel(
                theme: ExpandableThemeData(
                  iconColor: Colors.white
                ),
                header: Container(
                    color: Colors.grey[900],
                    child: Center(child: Text('Exercises'))
                ),
                collapsed: Text(''),
                expanded: ListView.builder(
                    shrinkWrap: true,
                    itemCount: db.getExerciseEntriesForDate(selectedDate.toString()).length,
                    itemBuilder: (context, index) {
                      // return Text(db.getExerciseEntriesForDate(selectedDate.toString()).toString());
                      return Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child:
                        Slidable(
                          endActionPane: ActionPane(
                              motion: StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) => deleteExercise(index),
                                  icon: Icons.delete,
                                )
                              ]
                          ),
                          child: Row(
                            children: [
                              Text('Name: ${db.getExerciseEntriesForDate(selectedDate.toString())
                                  [index].name.toString()}'
                                  '\nDuration: ${db.getExerciseEntriesForDate(selectedDate.toString())
                                  [index].duration.toString()} minutes'
                                  '\nCalories Burned: ${db.getExerciseEntriesForDate(selectedDate.toString())
                                  [index].calBurned.toString()}'
                              )
                            ],
                          ),
                        ),
                      );
                    }
                ),
            ),

            GroupedFoods(time: 'Morning',
                date: selectedDate, deleteFunction: deleteFood),
            GroupedFoods(time: 'Afternoon',
                date: selectedDate, deleteFunction: deleteFood,),
            GroupedFoods(time: 'Evening',
                date: selectedDate, deleteFunction: deleteFood,)

          ],
        ),
      ),
    );
  }
}
