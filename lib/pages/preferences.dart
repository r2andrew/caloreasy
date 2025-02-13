import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:caloreasy/components/sub_heading.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/tdee_dialog.dart';
import '../helpers/noti_service.dart';

class PreferencesPage extends StatefulWidget {

  Function goToTracker;

  PreferencesPage({
    super.key,
    required this.goToTracker
  });

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {

  DateTime todaysDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  LocalDatabase db = LocalDatabase();

  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  late bool notificationsOn;

  @override
  void initState() {

    var preferences = db.getPreferences(todaysDate.toString());

    _caloriesController.text = preferences['calories'].toString();
    _proteinController.text = preferences['protein'].toString();
    _carbsController.text = preferences['carbs'].toString();
    _fatController.text = preferences['fat'].toString();

    notificationsOn = db.getNotificationsStatus();

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
          db.updatePreferences(todaysDate.toString(), updatedPreferences);

          widget.goToTracker();
        }
  }

  Widget macroInput (String macro, TextEditingController controller) {
    return Center(
      child: SizedBox(
        width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Text(macro)),
            SizedBox(
              width: 100,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: macro
                ),
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Preferences')),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [

          Divider(height: 1, thickness: 1, color: Colors.grey[800],),

          // notification selector
          SubHeading(text: 'Macro Goals'),

          Divider(height: 1, thickness: 1, color: Colors.grey[800],),

          macroInput('Calories', _caloriesController),
          macroInput('Protein', _proteinController),
          macroInput('Carbs', _carbsController),
          macroInput('Fat', _fatController),

          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    color: Colors.grey[800],
                    textColor: Colors.white,
                    onPressed: openTDEECalcDialog,
                    child: Row(
                      children: [
                        Icon(Icons.calculate),
                        Text('Goal Calculator')
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                      color: Colors.grey[800],
                      textColor: Colors.white,
                      onPressed: () => submit(),
                      child: Row(
                        children: [
                          Icon(Icons.save),
                          Text('Save'),
                        ],
                      ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey[800],),
          SubHeading(text: 'Notifications'),
          Divider(height: 1, thickness: 1, color: Colors.grey[800],),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Off'),
                    Switch(
                      trackColor: WidgetStateProperty<Color?>.fromMap(<WidgetStatesConstraint, Color>{
                        WidgetState.selected: Colors.blue
                      }),
                      thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                      value: notificationsOn,
                      onChanged: (value) {
                        setState(() {
                          db.toggleNotificationsStatus();
                          notificationsOn = db.getNotificationsStatus();
                        });
                        if (notificationsOn == true) {
                          AndroidAlarmManager.periodic(const Duration(days: 1), 0, () => NotiService.scheduledNotification(),
                              startAt: todaysDate.copyWith(hour: 17), allowWhileIdle: true, wakeup: true, rescheduleOnReboot: true)
                              .then((value) => print('Alarm Timer Started = $value'));
                        } else {
                          AndroidAlarmManager.cancel(0).then((value) => print('Alarm Timer Canceled = $value'));
                        }
                      },
                    ),
                    Text('On')
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Send a reminder notification if no entries by 5pm',
                    style: TextStyle(color: Colors.grey[400])),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
