import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WeightDialog extends StatefulWidget {

  DateTime selectedDate;

  WeightDialog({
    super.key,
    required this.selectedDate
  });

  @override
  State<WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<WeightDialog> {

  final _weightController = TextEditingController();

  LocalDatabase db = LocalDatabase();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: ContinuousRectangleBorder(),
      content: SizedBox(
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Weight as of today',
                style: TextStyle(
                fontSize: 20,
                color: Colors.grey[400]),
              )
            ),

            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))
              ],
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))
                  ),
                  hintStyle: TextStyle(
                      color: Colors.white.withAlpha(150)
                  ),
                  hintText: 'Weight in KG'
              ),
              controller: _weightController,
            ),

            MaterialButton(
                color: Colors.blue,
                onPressed: () {
                  db.storeWeightForDate(
                      widget.selectedDate.toString(),
                      double.parse(_weightController.text)
                  );
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
            ),
          ]
        ),
      ),
    );
  }
}
