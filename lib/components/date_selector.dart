import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {

  DateTime selectedDate;
  Function updateDate;

  DateSelector({
    super.key,
    required this.selectedDate,
    required this.updateDate
  });

  DateTime todaysDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: MaterialButton(
              color: Colors.grey[800],
              onPressed: () => updateDate("back"),
              child: Text('Back'),
            ),
          ),
          Expanded(child: Center(child:
            Text('${selectedDate.day}/${selectedDate.month}/'
                '${selectedDate.year.toString().substring(2,4)}'))),
          // if viewing a past day, present a forward button
          Expanded(
            child: MaterialButton(
              color: selectedDate.isBefore(todaysDate) ? Colors.grey[800] : Colors.grey[800],
              onPressed: selectedDate.isBefore(todaysDate) ? () => updateDate("forward") : () => (),
              child: selectedDate.isBefore(todaysDate) ? Text('Forward') : Icon(Icons.not_interested),
            ),
          )
        ],
      ),
    );
  }
}
