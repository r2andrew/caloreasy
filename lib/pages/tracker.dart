import 'package:caloreasy/components/saved_food_tile.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:caloreasy/pages/add_food.dart';
import 'package:flutter/material.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {

  String selectedDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0)
      .toString();

  LocalDatabase db = LocalDatabase();

  void deleteFood (index) {
    setState(() {
      db.deleteFoodEntry(selectedDate, index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Tracker')),
        backgroundColor: Colors.black,
      ),
      
      // tap to open add food page
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () => {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => AddFoodPage(selectedDate: selectedDate)
            // rebuild widget on return from adding
            )).then((_) => setState(() {}))
          },
          child: Icon(Icons.add, color: Colors.black,),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
                shrinkWrap: true,
                itemCount: db.getFoodEntriesForDate(selectedDate).length,
                itemBuilder: (context, index) {
                  return SavedFoodTile(
                      food: db.getFoodEntriesForDate(selectedDate)[index],
                      deleteFunction: (context) => deleteFood(index),
                  );
                }
            )
          ],
        ),
      ),
    );
  }
}
