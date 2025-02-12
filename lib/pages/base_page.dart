import 'package:caloreasy/pages/add_exercise.dart';
import 'package:caloreasy/pages/add_food.dart';
import 'package:caloreasy/pages/graphs.dart';
import 'package:caloreasy/pages/preferences.dart';
import 'package:caloreasy/pages/tracker.dart';
import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {

  int _selectedIndex = 0;

  DateTime selectedDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  DateTime todaysDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  void navigateBottomBar (int index) {
    if (selectedDate == todaysDate) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void updateDate(String direction) {
    setState(() {
      direction == 'forward' ? selectedDate = selectedDate.add(Duration(days: 1)) :
          selectedDate = selectedDate.subtract(Duration(days: 1));
    });
  }

  void goToTracker () {
    setState(() {
      _selectedIndex = 0;
    });
  }

  Widget getPage (int index) {
    switch (index) {
      case 0:
        return TrackerPage();
      case 1:
        return PreferencesPage(goToTracker: goToTracker);
      default:
        return GraphsPage();
    }
  }

  final List<BottomNavigationBarItem> pageLabels = [
    BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: 'Tracker'
    ),
    BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Preferences'
    ),
    BottomNavigationBarItem(
        icon: Icon(Icons.auto_graph),
        label: 'Graphs'
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          showUnselectedLabels: true,
          unselectedItemColor: selectedDate == todaysDate ? Colors.white : Colors.grey[800],
          selectedItemColor: Colors.blue,
          currentIndex: _selectedIndex,
          onTap: navigateBottomBar,
          items: pageLabels
      ),
    );
  }
}
