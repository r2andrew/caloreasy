import 'package:caloreasy/pages/tracker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {

  await Hive.initFlutter();

  final _foodEntriesBox = await Hive.openBox('userFoodEntries');
  var _preferencesBox = await Hive.openBox('userPreferences');


  // debug
  // _foodEntriesBox.clear();

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
