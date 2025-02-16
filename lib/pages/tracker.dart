import 'package:caloreasy/components/daily_stats.dart';
import 'package:caloreasy/components/exercises.dart';
import 'package:caloreasy/components/grouped_foods.dart';
import 'package:caloreasy/components/two_tab_selector.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:caloreasy/pages/add_exercise.dart';
import 'package:caloreasy/pages/add_food.dart';
import 'package:flutter/material.dart';
import '../components/date_selector.dart';

class TrackerPage extends StatefulWidget {

  TrackerPage({
    super.key,
  });

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {

  DateTime selectedDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  DateTime todaysDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  LocalDatabase db = LocalDatabase();

  bool firstTabSelected = true;

  bool notificationOn = false;

  void updateDate(String direction) {
    setState(() {
      direction == 'forward' ? selectedDate = selectedDate.add(Duration(days: 1)) :
      selectedDate = selectedDate.subtract(Duration(days: 1));
    });
  }

  void deleteFood (id) {
    setState(() {
      db.deleteFoodEntry(selectedDate.toString(), id);
    });
  }
  
  void deleteExercise(index) {
    setState(() {
      db.deleteExerciseEntry(selectedDate.toString(), index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Tracker')),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: selectedDate == todaysDate ? FloatingActionButton(
          onPressed: () => {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
              firstTabSelected ?
                AddFoodPage(selectedDate: selectedDate.toString())
                : AddExercisePage(selectedDate: selectedDate.toString())
            )).then(((_) => setState(() {})))
          },
          shape: ContinuousRectangleBorder(),
          child: Icon(Icons.add),
      ) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [

            DailyStats(selectedDate: selectedDate.toString()),

            Divider(height: 1, thickness: 1, color: Colors.grey[800],),

            DateSelector(selectedDate: selectedDate, updateDate: updateDate),

            Divider(height: 1, thickness: 1, color: Colors.grey[800],),

            TwoTabSelector(
                firstTabSelected: firstTabSelected,
                updateTabSelection: (updatedSelection) => setState(() {firstTabSelected = updatedSelection;}),
                tabNames: ['Food', 'Exercises'],
                icons: [Icon(Icons.food_bank), Icon(Icons.run_circle)],
            ),

            Divider(height: 1, thickness: 1, color: Colors.grey[800],),

            firstTabSelected ?
              GroupedFoods(selectedDate: selectedDate, deleteFunction: deleteFood) :
              Exercises(selectedDate: selectedDate.toString(), deleteExercise: deleteExercise,)
          ],
        ),
      ),
    );
  }
}
