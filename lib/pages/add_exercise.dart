import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';

class AddExercisePage extends StatefulWidget {

  String selectedDate;
  Function goToTracker;

  AddExercisePage({
    super.key,
    required this.selectedDate,
    required this.goToTracker
  });

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {

  LocalDatabase db = LocalDatabase();

  String exercise = 'RUN';
  double minutes = 1;

  void submit() {
      db.addExerciseEntry(widget.selectedDate, exercise, minutes.toInt());
      widget.goToTracker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Exercise'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [

              DropdownButton(
                  hint: Text(exercise),
                  value: exercise,
                  items: [
                    DropdownMenuItem(
                        value: 'RUN',
                        child: Text('Run')
                    ),
                    DropdownMenuItem(
                        value: 'WALK',
                        child: Text('Walk')
                    ),
                    DropdownMenuItem(
                        value: 'SWIM',
                        child: Text('Swim')
                    ),
                  ],
                  onChanged: (chosenExercise) {
                    setState(() {
                      exercise = chosenExercise!;
                    });
                  }
              ),

              Slider(
                value: minutes,
                max: 60,
                divisions: 12,
                label: minutes.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    minutes = value;
                  });
                },
              ),

              MaterialButton(
                  color: Colors.white,
                  onPressed: submit,
                  textColor: Colors.black,
                  child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
