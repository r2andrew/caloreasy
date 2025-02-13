import 'package:flutter/material.dart';

class TwoTabSelector extends StatelessWidget {

  bool firstTabSelected;
  Function updateTabSelection;
  List<String> tabNames;
  List<Icon> icons;

  TwoTabSelector({
    super.key,
    required this.firstTabSelected,
    required this.updateTabSelection,
    required this.tabNames,
    required this.icons
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
                textColor: firstTabSelected ? Colors.blue : Colors.white,
                height: 60,
                onPressed: () => updateTabSelection(true),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tabNames[0]),
                    icons[0]
                  ],
                ),
              )
          ),
          Expanded(
              child: MaterialButton(
                textColor: !firstTabSelected ? Colors.blue : Colors.white,
                height: 60,
                onPressed: () => updateTabSelection(false),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tabNames[1]),
                    icons[1]
                  ],
                ),
              )
          )
        ],
      ),
    );
  }
}
