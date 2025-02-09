import 'package:caloreasy/components/saved_food_tile.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';

class GroupedFoods extends StatefulWidget {

  final DateTime selectedDate;
  final Function deleteFunction;

  const GroupedFoods({
    super.key,
    required this.selectedDate,
    required this.deleteFunction
  });

  @override
  State<GroupedFoods> createState() => _GroupedFoodsState();
}

class _GroupedFoodsState extends State<GroupedFoods> {

  final LocalDatabase db = LocalDatabase();

  // deletion needs to trigger a rebuild on tracker page therefore delete function
  // needs to reside in tracker page. however this widget must also be rebuilt on delete
  void deleteFood (id) {
    setState(() {
      widget.deleteFunction(id);
    });
  }

  Widget oneGroup (String time) {

    IconData icon;

    switch (time) {
      case 'Afternoon' : icon = Icons.cloud;
      case 'Evening' : icon = Icons.shield_moon;
      default : icon = Icons.sunny;
    }
    if (db.getFoodEntriesForDate(widget.selectedDate.toString())[time] == null) {
      return Container();
    }
    return Column(
        children: [
          Row(
            children: [
              Expanded(child: Container(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: Colors.grey[400],),
                        Text('\t$time', style: TextStyle(color: Colors.grey[400]),)
                      ],
                    ),
                  )
              )),
            ],
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[800],),

          ListView.builder(
              shrinkWrap: true,
              itemCount: db.getFoodEntriesForDate(widget.selectedDate.toString())[time]?.length ?? 0,
              itemBuilder: (context, index) {
                var food = db.getFoodEntriesForDate(widget.selectedDate.toString())[time]![index];
                return Column(
                  children: [
                    SavedFoodTile(
                      food: food,
                      deleteFunction: (context) => deleteFood(food.stores),
                      selectedDate: widget.selectedDate,
                    ),
                    Divider(height: 1, thickness: 1, color: Colors.black,),
                  ],
                );
              }
          )
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        oneGroup('Morning'),
        oneGroup('Afternoon'),
        oneGroup('Evening')
      ],
    );
  }
}
