import 'dart:io';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:caloreasy/components/returned_food_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:integration_test/integration_test.dart';
import 'package:caloreasy/main.dart';

void main() async {

  await Hive.initFlutter();

  final _foodEntriesBox = await Hive.openBox('userFoodEntries');
  _foodEntriesBox.clear();
  final _preferencesBox = await Hive.openBox('userPreferences');
  _preferencesBox.clear();
  final _exerciseEntriesBox = await Hive.openBox('userExerciseEntries');
  _exerciseEntriesBox.clear();
  final _notificationsBox = await Hive.openBox('notifications');
  _notificationsBox.clear();
  final _weightBox = await Hive.openBox('userWeightEntries');
  _weightBox.clear();

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) await AndroidAlarmManager.initialize();

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('basic nav', () {

    testWidgets('Tracker selection renders in navbar as blue (selected)', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      // find parents of list icons matching IconTheme to get color of icon
      // though there should only be one, multiple widgets are returned here.
      // the desired one always seems to be the first so just pull it.
      IconTheme TrackerIconTheme =
      (tester.firstWidget(find.ancestor(of: find.byIcon(Icons.list), matching: find.byType(IconTheme))));

      expect(TrackerIconTheme.data.color, Colors.blue);
    });

    testWidgets('Unselected nav pages are white', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      IconTheme GraphIconTheme =
      (tester.firstWidget(find.ancestor(of: find.byIcon(Icons.auto_graph), matching: find.byType(IconTheme))));

      expect(GraphIconTheme.data.color, Colors.white);
    });

  });

  group('add food', () {

    testWidgets('Search and add food', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      var searchField = find.ancestor(
          of: find.text('Search'),
          matching: find.byType(TextField));

      await tester.enterText(searchField, 'pringles');

      var gramsField = find.ancestor(
          of: find.text('grams'),
          matching: find.byType(TextField));

      await tester.enterText(gramsField, '50');

      await tester.pumpAndSettle();

      await tester.tap(find.text('Morning'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Afternoon'));

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump(Duration(seconds: 15));

      await tester.tap(find.byType(ReturnedFoodTile).first);

      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));

      await tester.pumpAndSettle();

      expect(find.text('Added'), findsOneWidget);
    });


    // TODO: add test to just open and close barcode scanner
  });

  group('add exercise', () {

    testWidgets('add exercise', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slider), Offset(100, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Run'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Swim'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // expect to be back on tracker page
      expect(find.text('Exercises'), findsOneWidget);

    });
  });

  group('preferences', () {
    
    testWidgets('add preferences with calc', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());
      
      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.calculate));
      await tester.pumpAndSettle();

      var weightField = find.ancestor(
          of: find.text('Weight in KG'),
          matching: find.byType(TextField));
      var heightField = find.ancestor(
          of: find.text('Height in CM'),
          matching: find.byType(TextField));
      var ageField = find.ancestor(
          of: find.text('Age'),
          matching: find.byType(TextField));
      
      await tester.enterText(weightField, '60');
      await tester.pumpAndSettle();

      await tester.enterText(heightField, '150');
      await tester.pumpAndSettle();

      await tester.enterText(ageField, '21');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();

      // choose different options for sex and goal
      await tester.tap(find.byIcon(Icons.calculate));
      await tester.pumpAndSettle();

      await tester.enterText(weightField, '60');
      await tester.pumpAndSettle();

      await tester.enterText(heightField, '150');
      await tester.pumpAndSettle();

      await tester.enterText(ageField, '21');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Male'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lose Fat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gain Muscle'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // TODO: add test to just toggle notif on and off
    });

    testWidgets('manually edit pref so bar is green', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();

      // 51 calories over whats been input so far
      await tester.enterText(find.byType(TextField).first, '500');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect((tester.firstWidget(find.byType(LinearProgressIndicator)) as LinearProgressIndicator).color, Colors.green);

    });

  });

  group('graphs', () {
    testWidgets("calorie delta graph can't go forward in time", (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Graphs'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.not_interested), findsOneWidget);
    });

    testWidgets("weight graph add", (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Graphs'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weight'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '60');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.not_interested), findsOneWidget);
    });

    testWidgets("can't add weight if looking at past date", (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Graphs'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weight'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);

    });

  });

  group('coachpilot', () {
    // ask for advice when under budget, receive food tips
    testWidgets('get food tips', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());
      
      await tester.tap(find.text('CoachPilot'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle(Duration(seconds: 10));
      
      expect(find.textContaining(RegExp('food|snack|nutrient', caseSensitive: false)), findsOneWidget);
    });

    // delete exercise, over budget, receive exercise tips
    testWidgets('get exercise tips', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      await tester.drag(find.byIcon(Icons.sports_football), Offset(-200, 0));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CoachPilot'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle(Duration(seconds: 10));

      expect(find.textContaining(RegExp('exercise|workout|train', caseSensitive: false)), findsOneWidget);
    });

  });

  group('delete food', () {

    testWidgets('Delete added food', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Pringles Original'), findsAtLeastNWidgets(1));

      await tester.drag(find.text('Pringles Original'), Offset(-200, 0));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Pringles Original'), findsNothing);
    });

  });
}

// TODO: unit tests:
// barcode scanning
// 5pm notif?
// food api error handling
// ai api error handling