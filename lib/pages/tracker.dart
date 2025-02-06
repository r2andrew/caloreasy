import 'package:caloreasy/components/grouped_foods.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class TrackerPage extends StatefulWidget {

  Function updateDate;
  DateTime selectedDate;

  TrackerPage({
    super.key,
    required this.updateDate,
    required this.selectedDate
  });

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {

  DateTime todaysDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  LocalDatabase db = LocalDatabase();

  String tabSelection = 'food';

  bool notificationOn = false;

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
      var foodList = db.getFoodEntriesForDate(widget.selectedDate.toString())[time] ?? [];
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
    var exerciseList = db.getExerciseEntriesForDate(widget.selectedDate.toString());
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
    (nutrientConsumedToday / (db.getPreferences(widget.selectedDate.toString())[nutrient]));

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
        widget.updateDate(widget.selectedDate.add(Duration(days: 1)));
      } else {
        widget.updateDate(widget.selectedDate.subtract(Duration(days: 1)));
      }
      calcNutrientsConsumedToday();
    });
  }

  void deleteFood (id) {
    setState(() {
      db.deleteFoodEntry(widget.selectedDate.toString(), id);
      calcNutrientsConsumedToday();
    });
  }
  
  void deleteExercise(index) {
    setState(() {
      db.deleteExerciseEntry(widget.selectedDate.toString(), index);
    });
  }

  Widget DateSelector () {
    // only display forward option if widget.selectedDate is before todaysDate
    // (can't select future dates)
    if (widget.selectedDate.isBefore(todaysDate)) {
      return Container(
        color: Colors.blue.withAlpha(50),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                color: Colors.grey[800],
                onPressed: () => changeSelectedDate("back"),
                child: Text('Back'),
              ),
              Text('${widget.selectedDate.day}-${widget.selectedDate.month}-${widget.selectedDate
                  .year}'),
              MaterialButton(
                color: Colors.grey[800],
                onPressed: () => changeSelectedDate("forward"),
                child: Text('Forward'),
              )
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                color: Colors.grey[800],
                onPressed: () => changeSelectedDate("back"),
                child: Text('Back'),
              ),
              Text('${widget.selectedDate.day}-${widget.selectedDate.month}-${widget.selectedDate
                  .year}'),
              SizedBox(width: 80, height: 20)
            ],
          ),
        ),
      );
    }
  }
  
  Widget itemsView () {
    if (tabSelection == 'food') {
      return GroupedFoods(date: widget.selectedDate, deleteFunction: deleteFood);
    } else {
      return Container(
        color: Colors.grey[800],
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: db.getExerciseEntriesForDate(widget.selectedDate.toString()).length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                ),
                child: Column(
                  children: [
                    Slidable(
                      endActionPane: ActionPane(
                          motion: StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => deleteExercise(index),
                              icon: Icons.delete,
                              backgroundColor: Colors.red,
                            )
                          ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text('Name: ${db.getExerciseEntriesForDate(widget.selectedDate.toString())
                            [index].name.toString()}'
                                '\nDuration: ${db.getExerciseEntriesForDate(widget.selectedDate.toString())
                            [index].duration.toString()} minutes'
                                '\nCalories Burned: ${db.getExerciseEntriesForDate(widget.selectedDate.toString())
                            [index].calBurned.toString()}'
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      indent: 0,
                      height: 5,
                      thickness: 1,
                      color: Colors.white,
                    ),
                  ],
                ),
              );
            }
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

      body: SingleChildScrollView(
        child: Column(
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
                      value: calcNutrientDelta(caloriesConsumedToday - caloriesBurnedToday, 'calories')[0],
                      color: calcNutrientDelta(caloriesConsumedToday - caloriesBurnedToday, 'calories')[1],
                      backgroundColor: Colors.blue.withAlpha(50),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('${caloriesConsumedToday} (-${caloriesBurnedToday}) / ${db.getPreferences(widget.selectedDate.toString())['calories']} Calories'),
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
                        '${db.getPreferences(widget.selectedDate.toString())['calories'].toString()}'
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
                        '${db.getPreferences(widget.selectedDate.toString())['carbs'].toString()}'
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
                        '${db.getPreferences(widget.selectedDate.toString())['fat'].toString()}'
                    )
                  ],
                ),
              ),
            ),

            Divider(height: 5, thickness: 1, color: Colors.grey[600],),

            DateSelector(),

            Divider(height: 5, thickness: 1, color: Colors.grey[600],),

            // TODO: notification testing
            // Container(
            //   color: Colors.grey,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       MaterialButton(
            //         color: Colors.white,
            //         textColor: Colors.black,
            //         onPressed: () => NotiService().showNotification(title: 'Title', body: 'Body'),
            //         child: Text('TEST: Notif'),
            //       ),
            //       Row(
            //         children: [
            //           Text('Notifs Off'),
            //           Switch(
            //             value: notificationOn,
            //             onChanged: (value) {
            //               setState(() {
            //                 notificationOn = value;
            //               });
            //               if (notificationOn == true) {
            //                 AndroidAlarmManager.periodic(const Duration(days: 1), 0, () => NotiService.scheduledNotification(),
            //                     startAt: todaysDate.copyWith(hour: 17), allowWhileIdle: true, wakeup: true, rescheduleOnReboot: true)
            //                     .then((value) => print('Alarm Timer Started = $value'));
            //               } else {
            //                 AndroidAlarmManager.cancel(0).then((value) => print('Alarm Timer Canceled = $value'));
            //               }
            //             },
            //           ),
            //           Text('Notifs on'),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            Container(
              color: Colors.black,
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: MaterialButton(
                        // (selected == 'food') ? blue : white
                          textColor: (tabSelection == 'food') ? Colors.blue : Colors.white,
                          height: 60,
                          onPressed: () => setState(() {
                            tabSelection = 'food';
                          }),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Food'),
                              Icon(Icons.food_bank)
                            ],
                          ),
                      )
                  ),
                  Expanded(
                      child: MaterialButton(
                        textColor: (tabSelection == 'exercise') ? Colors.blue : Colors.white,
                        height: 60,
                        onPressed: () => setState(() {
                          tabSelection = 'exercise';
                        }),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Exercises'),
                            Icon(Icons.run_circle)
                          ],
                        ),
                      )
                  )
                ],
              ),
            ),
            
            itemsView(),
          ],
        ),
      ),
    );
  }
}
