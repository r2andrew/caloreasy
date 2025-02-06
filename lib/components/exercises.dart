import 'package:caloreasy/database/local_database.dart';
import 'package:caloreasy/helpers/capitilization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Exercises extends StatelessWidget {

  String selectedDate;
  Function deleteExercise;

  Exercises({
    super.key,
    required this.selectedDate,
    required this.deleteExercise
  });

  LocalDatabase db = LocalDatabase();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[800],
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: db.getExerciseEntriesForDate(selectedDate).length,
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
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sports_football),
                              Text(' ${db.getExerciseEntriesForDate(selectedDate)
                                [index].name.toString().sentenceCase()}')
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.lock_clock),
                              Text(' ${db.getExerciseEntriesForDate(selectedDate)
                                [index].duration.toString()}m')
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.fireplace),
                              Text(' ${db.getExerciseEntriesForDate(selectedDate)
                                [index].calBurned.toString()}')
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 2,
                    color: Colors.black,
                  ),
                ],
              ),
            );
          }
      ),
    );
  }
}
