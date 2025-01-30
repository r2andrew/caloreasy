import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TDEEDialog extends StatefulWidget {

  Function(int, int, int, String, double, String) generateGoals;

  TDEEDialog({
    super.key,
    required this.generateGoals
  });

  @override
  State<TDEEDialog> createState() => _TDEEDialogState();
}

class _TDEEDialogState extends State<TDEEDialog> {

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String sex = 'Male';
  double activityLevelModifier = 1.2;
  String goal = 'Lose Fat';

  void submit() {
    if (_weightController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _ageController.text.isNotEmpty) {
      widget.generateGoals(
          int.parse(_weightController.text),
          int.parse(_heightController.text),
          int.parse(_ageController.text),
          sex,
          activityLevelModifier,
          goal
      );
      // close dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 400,
        child: Column(
          children: [
            Text('TDEE Calculator'),

            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Weight in KG'
              ),
              controller: _weightController,
            ),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Height in CM'
              ),
              controller: _heightController,
            ),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Age'
              ),
              controller: _ageController,
            ),
            DropdownButton(
                hint: Text(sex),
                value: sex,
                items: [
                  DropdownMenuItem(
                      value: 'Male',
                      child: Text('Male')
                  ),
                  DropdownMenuItem(
                      value: 'Female',
                      child: Text('Female')
                  ),
                ],
                onChanged: (chosenSex) {
                  setState(() {
                    sex = chosenSex!;
                  });
                }
            ),
            DropdownButton(
                hint: Text(activityLevelModifier.toString()),
                value: activityLevelModifier,
                items: [
                  DropdownMenuItem(
                      value: 1.2,
                      child: Text('Sedentary')
                  ),
                  DropdownMenuItem(
                      value: 1.375,
                      child: Text('Light Exercise')
                  ),
                  DropdownMenuItem(
                      value: 1.55,
                      child: Text('Moderate Exercise')
                  ),
                  DropdownMenuItem(
                      value: 1.725,
                      child: Text('Heavy Exercise')
                  ),
                  DropdownMenuItem(
                      value: 1.9,
                      child: Text('Athlete')
                  ),
                ],
                onChanged: (chosenActivityLevel) {
                  setState(() {
                    activityLevelModifier = chosenActivityLevel!;
                  });
                }
            ),
            DropdownButton(
                hint: Text(goal),
                value: goal,
                items: [
                  DropdownMenuItem(
                      value: 'Lose Fat',
                      child: Text('Lose Fat')
                  ),
                  DropdownMenuItem(
                      value: 'Maintain',
                      child: Text('Maintain')
                  ),
                  DropdownMenuItem(
                      value: 'Gain Muscle',
                      child: Text('Gain Muscle')
                  ),
                ],
                onChanged: (chosenGoal) {
                  setState(() {
                    goal = chosenGoal!;
                  });
                }
            ),

            MaterialButton(
              color: Colors.white,
              textColor: Colors.black,
              onPressed: () => submit(),
              child: Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
