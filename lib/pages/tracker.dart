import 'package:caloreasy/components/daily_stats.dart';
import 'package:caloreasy/components/exercises.dart';
import 'package:caloreasy/components/grouped_foods.dart';
import 'package:caloreasy/components/tracker_view_selector.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';
import '../components/date_selector.dart';

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

  LocalDatabase db = LocalDatabase();

  String tabSelection = 'food';

  bool notificationOn = false;

  void deleteFood (id) {
    setState(() {
      db.deleteFoodEntry(widget.selectedDate.toString(), id);
    });
  }
  
  void deleteExercise(index) {
    setState(() {
      db.deleteExerciseEntry(widget.selectedDate.toString(), index);
    });
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

            DailyStats(selectedDate: widget.selectedDate.toString()),

            Divider(height: 1, thickness: 1, color: Colors.grey[800],),

            DateSelector(selectedDate: widget.selectedDate, updateDate: widget.updateDate),

            Divider(height: 1, thickness: 1, color: Colors.grey[800],),

            TrackerViewSelector(
                tabSelection: tabSelection,
                updateTabSelection: (updatedSelection) => setState(() {tabSelection = updatedSelection;})),

            Divider(height: 1, thickness: 1, color: Colors.grey[800],),

            tabSelection == 'food' ?
              GroupedFoods(selectedDate: widget.selectedDate, deleteFunction: deleteFood) :
              Exercises(selectedDate: widget.selectedDate.toString(), deleteExercise: deleteExercise,)
          ],
        ),
      ),
    );
  }
}
