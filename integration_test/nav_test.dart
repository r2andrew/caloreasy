import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:caloreasy/helpers/noti_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:integration_test/integration_test.dart';
import 'package:caloreasy/main.dart';

import 'dart:developer';

void main() async {

  await Hive.initFlutter();

  final _foodEntriesBox = await Hive.openBox('userFoodEntries');
  final _preferencesBox = await Hive.openBox('userPreferences');
  final _exerciseEntriesBox = await Hive.openBox('userExerciseEntries');
  final _notificationsBox = await Hive.openBox('notifications');
  final _weightBox = await Hive.openBox('userWeightEntries');

  WidgetsFlutterBinding.ensureInitialized();

  // get notifications permission / init service
  NotiService().initNotification();

  // initialise Alarm (notif scheduler) service if on android
  // debugging on linux crashes otherwise
  if (Platform.isAndroid) await AndroidAlarmManager.initialize();

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('nav tests - integration', () {

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

    testWidgets('Tapping changes page', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      IconTheme TrackerIconTheme =
      (tester.firstWidget(find.ancestor(of: find.byIcon(Icons.list), matching: find.byType(IconTheme))));

      IconTheme PreferencesIconTheme =
      (tester.firstWidget(find.ancestor(of: find.byIcon(Icons.settings), matching: find.byType(IconTheme))));

      expect(TrackerIconTheme.data.color != Colors.blue, true);
      expect(PreferencesIconTheme.data.color, Colors.blue);
    });

    testWidgets('Tapping Graphs goes to graph page', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byIcon(Icons.auto_graph));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.monitor_weight), findsOneWidget);
    });

    testWidgets('Tapping Coachpilot goes to Coachpilot page', (
        tester,
        ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byIcon(Icons.science));
      await tester.pumpAndSettle();

      expect(find.text('Ask'), findsOneWidget);
    });

  });
}