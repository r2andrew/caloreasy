import 'dart:io';
import 'package:caloreasy/helpers/customFoodAPIClient.dart';
import 'package:caloreasy/pages/add_food.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'data.dart';
import 'unit_test.mocks.dart';

@GenerateMocks([customFoodAPIClient])
void main () async {
  var path = Directory.current.path;
  Hive.init(path + '/test/hive_testing_path');

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

  DateTime selectedDate = DateTime.now()
      .copyWith(hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0);

  group('food service', () {
    testWidgets('handle api success', (tester,) async {
      MockcustomFoodAPIClient mockcustomFoodAPIClient = MockcustomFoodAPIClient();
      when(mockcustomFoodAPIClient.searchProducts(any)).thenAnswer((_) async =>
          SearchResult.fromJson(successResultTyped[0]));

      await tester.pumpWidget(MaterialApp(
        home: AddFoodPage(selectedDate: selectedDate.toString(),
          client: mockcustomFoodAPIClient,),
      ));

      var searchField = find.ancestor(
          of: find.text('Search'),
          matching: find.byType(TextField));

      await tester.enterText(searchField, 'pringles');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('pringles'), findsOneWidget);
    });

    testWidgets('handle api failure', (tester,) async {
      MockcustomFoodAPIClient mockcustomFoodAPIClient = MockcustomFoodAPIClient();
      when(mockcustomFoodAPIClient.searchProducts(any)).thenAnswer((_) async =>
          SearchResult.fromJson(failResultTyped[0]));

      await tester.pumpWidget(MaterialApp(
        home: AddFoodPage(selectedDate: selectedDate.toString(),
          client: mockcustomFoodAPIClient,),
      ));

      var searchField = find.ancestor(
          of: find.text('Search'),
          matching: find.byType(TextField));

      await tester.enterText(searchField, 'pringles');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('No items found'), findsOneWidget);
    });
  });
}
