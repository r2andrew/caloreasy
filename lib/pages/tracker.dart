import 'package:caloreasy/components/grouped_foods.dart';
import 'package:caloreasy/components/saved_food_tile.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:caloreasy/pages/add_food.dart';
import 'package:caloreasy/pages/preferences.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {

  DateTime selectedDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  LocalDatabase db = LocalDatabase();

  int caloriesConsumedToday = 0;

  @override
  void initState() {
    calcCaloriesConsumedToday();
    super.initState();
  }

  void calcCaloriesConsumedToday() {

    int caloriesConsumed = 0;

    var times = ['Morning', 'Afternoon', 'Evening'];

    for (var time in times) {
      var foodList = db.getFoodEntriesForDate(selectedDate.toString())[time] ?? [];
      for (var food in foodList) {
        caloriesConsumed += (food.nutriments!.getComputedKJ(PerSize.oneHundredGrams)! *
            (int.parse(food.quantity!) / 100)).toInt();
      }
    }
    setState(() {
      caloriesConsumedToday = caloriesConsumed;
    });
  }

  List calcCalorieDelta() {
    double percentageFilled =
    (caloriesConsumedToday / (db.getPreferences('calories')));

    if (percentageFilled.isInfinite || percentageFilled.isNaN) {
      percentageFilled = 0;
    }

    if (percentageFilled < 0.5) {
      return [percentageFilled, Colors.green];
    }
    return [percentageFilled, Colors.red];
  }

  void changeSelectedDate(String direction) {
    setState(() {
      if (direction == "forward") {
        selectedDate = selectedDate.add(Duration(days: 1));
      } else {
        selectedDate = selectedDate.subtract(Duration(days: 1));
      }
      calcCaloriesConsumedToday();
    });
  }

  void deleteFood (id) {
    setState(() {
      db.deleteFoodEntry(selectedDate.toString(), id);
      calcCaloriesConsumedToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Tracker')),
        backgroundColor: Colors.black,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              FloatingActionButton(
                heroTag: 'Preferences',
                backgroundColor: Colors.white,
                onPressed: () => {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => PreferencesPage()
                    // rebuild widget on return from adding
                  )).then((_) => setState(() {}))
                },
                child: Icon(Icons.edit, color: Colors.black,),
              ),

              FloatingActionButton(
                heroTag: 'Add',
                backgroundColor: Colors.white,
                onPressed: () => {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AddFoodPage(selectedDate: selectedDate.toString())
                    // rebuild widget on return from adding
                  )).then((_) => setState(() {calcCaloriesConsumedToday();}))
                },
                child: Icon(Icons.add, color: Colors.black,),
              )

            ],
          ),
      ),

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
                      value: calcCalorieDelta()[0],
                      color: calcCalorieDelta()[1],
                      backgroundColor: Colors.blue.withAlpha(50),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('${caloriesConsumedToday} / ${db.getPreferences('calories')} Calories'),
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    color: Colors.grey[800],
                    onPressed: () => changeSelectedDate("back"),
                    child: Text('Back'),
                  ),
                  Text('${selectedDate.day}-${selectedDate.month}-${selectedDate.year}'),
                  MaterialButton(
                    color: Colors.grey[800],
                    onPressed: () => changeSelectedDate("forward"),
                    child: Text('Forward'),
                  )
                ],
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
