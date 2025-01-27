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

  DateTime selectedDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  LocalDatabase db = LocalDatabase();

  void changeSelectedDate(String direction) {
    setState(() {
      if (direction == "forward") {
        selectedDate = selectedDate.add(Duration(days: 1));
      } else {
        selectedDate = selectedDate.subtract(Duration(days: 1));
      }
    });
  }

  void deleteFood (id) {
    setState(() {
      db.deleteFoodEntry(selectedDate.toString(), id);
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
                builder: (context) => AddFoodPage(selectedDate: selectedDate.toString())
            // rebuild widget on return from adding
            )).then((_) => setState(() {}))
          },
          child: Icon(Icons.add, color: Colors.black,),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

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

            ListView.builder(
                shrinkWrap: true,
                itemCount: db.getFoodEntriesForDate(selectedDate.toString()).length,
                itemBuilder: (context, index) {
                  var food = db.getFoodEntriesForDate(selectedDate.toString())[index];
                  return SavedFoodTile(
                      food: food,
                      deleteFunction: (context) => deleteFood(food.stores),
                  );
                }
            )
          ],
        ),
      ),
    );
  }
}
