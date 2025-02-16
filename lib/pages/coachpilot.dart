import 'package:caloreasy/helpers/coachpilot_service.dart';
import 'package:flutter/material.dart';
import '../database/local_database.dart';

class Coachpilot extends StatefulWidget {
  const Coachpilot({super.key});

  @override
  State<Coachpilot> createState() => _CoachpilotState();
}

class _CoachpilotState extends State<Coachpilot> {

  LocalDatabase db = LocalDatabase();

  DateTime selectedDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  late CoachpilotService aiService;

  String response = "Hi! I'm 🤖 CoachPilot, press the button below to get advice "
      "on reaching your goals today! 😄";

  bool loading = false;

  void loadResults (bool loaded, [String? apiResponse]) {
    if (!loaded) {
      setState(() {
        loading = true;
        response = '';
      });
    } else {
      setState(() {
        response = apiResponse!;
        loading = false;
      });
    }
  }

  int calorieDeltaToday() {
    Map nutrientsForDay = db.calcNutrientsConsumedForDay(selectedDate.toString());
    int caloriesForDay = nutrientsForDay['caloriesConsumed'] - nutrientsForDay['caloriesBurned'];

    int goalCaloriesForDay = db.getPreferences(selectedDate.toString())['calories'];

    return goalCaloriesForDay - caloriesForDay;
  }

  String questionForAI() {
    if (calorieDeltaToday() >= 0) {
      return 'What should I eat for ${calorieDeltaToday()} calories?';
    } else {
      return 'I need to burn ${calorieDeltaToday().abs()} '
          'calories to reach my goals, '
          'what exercise would you recommend?';
    }
  }

  @override
  void initState() {
    aiService = CoachpilotService(loadResults);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('CoachPilot')),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          loading == true ? Expanded(child: Center(child: CircularProgressIndicator(color: Colors.blue))
          ) : Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(response, textAlign: TextAlign.center,),
                  ],
                )
              ),
          Container(
            color: Colors.grey[800],
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                   color: Colors.blue,
                   onPressed: () => aiService.getChefsResponse(questionForAI()),
                   child: Text('Ask'),
                 ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
