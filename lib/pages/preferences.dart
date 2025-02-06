import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/tdee_dialog.dart';

class PreferencesPage extends StatefulWidget {

  String selectedDate;
  Function goToTracker;

  PreferencesPage({
    super.key,
    required this.selectedDate,
    required this.goToTracker
  });

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {

  LocalDatabase db = LocalDatabase();

  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void initState() {

    var preferences = db.getPreferences(widget.selectedDate);

    _caloriesController.text = preferences['calories'].toString();
    _proteinController.text = preferences['protein'].toString();
    _carbsController.text = preferences['carbs'].toString();
    _fatController.text = preferences['fat'].toString();

    super.initState();
  }


  void openTDEECalcDialog () {
    showDialog(context: context, builder: (context) {
      return TDEEDialog(
          generateGoals: generateGoals,
      );
    });
  }

  void generateGoals(int weight, int cm, int age,
      String sex, double activityLevelModifier, String goal) {

    var TDEE;

    if (sex == 'Male') {
      TDEE = ((10 * weight) + (6.25 * cm) - (5 * age) + 5) * activityLevelModifier;
    } else {
      TDEE = ((10 * weight) + (6.25 * cm) - (5 * age) - 161) * activityLevelModifier;
    }

    if (goal == 'Lose Fat') {
      TDEE -= 500;
    } else if (goal == 'Gain Muscle') {
      TDEE += 500;
    }

    setState(() {
      _caloriesController.text = TDEE.toInt().toString();
      _proteinController.text = ((TDEE * 0.4) ~/ 4).toString();
      _carbsController.text = ((TDEE * 0.4) ~/ 4).toString();
      _fatController.text = ((TDEE * 0.2) ~/ 9).toString();
    });
  }

  void submit() {
    if (_caloriesController.text.isNotEmpty &&
        _proteinController.text.isNotEmpty &&
        _carbsController.text.isNotEmpty &&
        _fatController.text.isNotEmpty) {
      
          Map updatedPreferences = {
            'calories': int.parse(_caloriesController.text),
            'protein': int.parse(_proteinController.text),
            'carbs': int.parse(_carbsController.text),
            'fat': int.parse(_fatController.text),
          };
          db.updatePreferences(widget.selectedDate, updatedPreferences);

          widget.goToTracker();
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: openTDEECalcDialog,
          child: Icon(Icons.calculate),
      ),
      body: Column(
        children: [

          Text('Calories'),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Calories'
            ),
            controller: _caloriesController,
          ),

          Text('Protein'),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Protein in g'
            ),
            controller: _proteinController,
          ),

          Text('Carbs'),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Carbs in g'
            ),
            controller: _carbsController,
          ),

          Text('Fat'),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Fat in g'
            ),
            controller: _fatController,
          ),

          MaterialButton(
              color: Colors.white,
              textColor: Colors.black,
              onPressed: () => submit(),
              child: Text('Save'),
          )
        ],
      ),
    );
  }
}
