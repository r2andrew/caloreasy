import 'package:caloreasy/pages/tracker.dart';
import 'package:flutter/material.dart';

void main() {
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
