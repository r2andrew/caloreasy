import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {

  LocalDatabase db = LocalDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Slider(
              value: db.getPreferences('calories'),
              divisions: 10,
              onChanged: (double value) {
                setState(() {
                  db.updatePreferences('calories', value);
                });
              }
          )
        ],
      ),
    );
  }
}
