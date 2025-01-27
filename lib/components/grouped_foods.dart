import 'package:caloreasy/components/saved_food_tile.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';

class GroupedFoods extends StatefulWidget {

  final String time;
  final DateTime date;

  const GroupedFoods({
    super.key,
    required this.time,
    required this.date
  });

  @override
  State<GroupedFoods> createState() => _GroupedFoodsState();
}

class _GroupedFoodsState extends State<GroupedFoods> {

  final LocalDatabase db = LocalDatabase();

  void deleteFood (id) {
    setState(() {
      db.deleteFoodEntry(widget.date.toString(), id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // if entries exist for this time, return nothing
    if (db.getFoodEntriesForDate(widget.date.toString())[widget.time] == null) {
      return Container();
    }
    return Column(
      children: [
        Text(widget.time),
        ListView.builder(
            shrinkWrap: true,
            itemCount: db.getFoodEntriesForDate(widget.date.toString())[widget.time]?.length ?? 0,
            itemBuilder: (context, index) {
              var food = db.getFoodEntriesForDate(widget.date.toString())[widget.time]![index];
              return SavedFoodTile(
                food: food,
                deleteFunction: (context) => deleteFood(food.stores),
              );
            }
        )
      ]
    );
  }
}
