import 'package:flutter/material.dart';

class TrackerViewSelector extends StatelessWidget {

  String tabSelection;
  Function updateTabSelection;

  TrackerViewSelector({
    super.key,
    required this.tabSelection,
    required this.updateTabSelection
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: MaterialButton(
                // (selected == 'food') ? blue : white
                textColor: (tabSelection == 'food') ? Colors.blue : Colors.white,
                height: 60,
                onPressed: () => updateTabSelection('food'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Food'),
                    Icon(Icons.food_bank)
                  ],
                ),
              )
          ),
          Expanded(
              child: MaterialButton(
                textColor: (tabSelection == 'exercise') ? Colors.blue : Colors.white,
                height: 60,
                onPressed: () => updateTabSelection('exercise'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Exercises'),
                    Icon(Icons.run_circle)
                  ],
                ),
              )
          )
        ],
      ),
    );
  }
}
