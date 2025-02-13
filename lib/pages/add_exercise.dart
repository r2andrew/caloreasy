import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';

class AddExercisePage extends StatefulWidget {

  String selectedDate;

  AddExercisePage({
    super.key,
    required this.selectedDate,
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
      Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Add Exercise')),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: SliderTheme(
                      data: SliderThemeData(
                        valueIndicatorColor: Colors.blue,
                        valueIndicatorTextStyle: TextStyle(color: Colors.white),
                        activeTrackColor: Colors.blue,
                        thumbColor: Colors.blue
                      ),
                      child: Slider(
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
                    ),
                  ),
                  Text('mins', style: TextStyle(color: Colors.grey[400]),)
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    MaterialButton(
                        color: Colors.grey[800],
                        textColor: Colors.white,
                        onPressed: submit,
                        child: Text('Add'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
