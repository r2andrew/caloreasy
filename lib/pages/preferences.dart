import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {

  LocalDatabase db = LocalDatabase();

  final _TextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [

          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Calories'
            ),
            controller: _TextController,
          ),
          MaterialButton(
              color: Colors.white,
              textColor: Colors.black,
              onPressed: () =>
                  db.updatePreferences('calories', int.parse(_TextController.text)),
              child: Text('Save'),
          )
        ],
      ),
    );
  }
}
