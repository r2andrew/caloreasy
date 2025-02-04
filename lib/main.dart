import 'package:caloreasy/helpers/noti_service.dart';
import 'package:caloreasy/pages/tracker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {

  await Hive.initFlutter();

  final _foodEntriesBox = await Hive.openBox('userFoodEntries');
  final _preferencesBox = await Hive.openBox('userPreferences');
  final _exerciseEntriesBox = await Hive.openBox('userExerciseEntries');

  // debug
  // _foodEntriesBox.clear();
  // _preferencesBox.clear();
  // _exerciseEntriesBox.clear();

  WidgetsFlutterBinding.ensureInitialized();

  // get notifications permission
  NotiService().initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caloreasy',
      theme: ThemeData(
        colorScheme: ColorScheme.highContrastDark(),
        useMaterial3: true,
      ),
      home: TrackerPage(),
    );
  }
}
