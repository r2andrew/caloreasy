import 'package:caloreasy/components/saved_food_tile.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';

class GroupedFoods extends StatefulWidget {

  final DateTime date;
  final Function deleteFunction;

  const GroupedFoods({
    super.key,
    required this.date,
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
    if (db.getFoodEntriesForDate(widget.date.toString())[time] == null) {
      return Container();
    }
    return Column(
        children: [
          Text(time),
          ListView.builder(
              shrinkWrap: true,
              itemCount: db.getFoodEntriesForDate(widget.date.toString())[time]?.length ?? 0,
              itemBuilder: (context, index) {
                var food = db.getFoodEntriesForDate(widget.date.toString())[time]![index];
                return SavedFoodTile(
                  food: food,
                  deleteFunction: (context) => deleteFood(food.stores),
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
