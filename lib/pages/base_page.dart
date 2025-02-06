import 'package:caloreasy/pages/add_exercise.dart';
import 'package:caloreasy/pages/add_food.dart';
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
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateDate(DateTime changedDate) {
    setState(() {
      selectedDate = changedDate;
    });
  }

  void goToTracker () {
    print('updated');
    setState(() {
      _selectedIndex = 0;
    });
  }

  Widget getPage (int index) {
    switch (index) {
      case 1:
        return PreferencesPage(
            selectedDate: selectedDate.toString(),
            goToTracker: goToTracker
        );
      case 2:
        return AddExercisePage(
            selectedDate: selectedDate.toString(),
            goToTracker: goToTracker
        );
      case 3:
        return AddFoodPage(
            selectedDate: selectedDate.toString()
        );
      default:
        return TrackerPage(updateDate: updateDate, selectedDate: selectedDate);
    }
  }

  Widget navBar () {
    if (selectedDate == todaysDate) {
      return Scaffold(
        body: getPage(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: true,
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.blue,
            currentIndex: _selectedIndex,
            onTap: navigateBottomBar,
            items: [
              BottomNavigationBarItem(
                  backgroundColor: Colors.black,
                  icon: Icon(Icons.list),
                  label: 'Tracker'
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Preferences'
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.run_circle),
                  label: 'Exercise'
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.food_bank),
                  label: 'Food'
              ),
            ]
        ),
      );
    } else {
      return Scaffold(
        body: TrackerPage(updateDate: updateDate, selectedDate: selectedDate),
        bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: true,
            unselectedItemColor: Colors.grey[800],
            selectedItemColor: Colors.blue,
            currentIndex: 0,
            items: [
              BottomNavigationBarItem(
                  backgroundColor: Colors.black,
                  icon: Icon(Icons.list),
                  label: 'Tracker'
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Preferences'
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.run_circle),
                  label: 'Exercise'
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.food_bank),
                  label: 'Food'
              ),
            ]
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return navBar();
  }
}
