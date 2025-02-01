import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class LocalDatabase {

  // reference the hive box

  // List<Map<String, dynamic>>
  final _foodEntriesBox = Hive.box('userFoodEntries');
  // Map
  final _preferencesBox = Hive.box('userPreferences');

  /*
  * FOOD METHODS
  * */

  // Hive can't store objects, they must be serialised into JSON string
  // except it can barely handle that even
  // It converts List<Map<String, dynamic>> into List<dynamic>
  // which breaks the Product.fromJson de-serializer
  // So this unsavoury function is necessary to fix the type
  List<Map<String, dynamic>> readList (String date) {
    var dynamicList = _foodEntriesBox.get(date, defaultValue: []);
    var fixedType =
        (jsonDecode(jsonEncode(dynamicList)) as List)
            .cast<Map<String, dynamic>>();

    return fixedType;
  }

  Map<String, List<Product>> getFoodEntriesForDate(String date) {

    List<Product> foods = [];

    // decode json string back into Product
    for (final serialisedFood in readList(date)) {
      foods.add(Product.fromJson(serialisedFood));
    }

    // group by time
    Map<String, List<Product>> grouped = {};

    for (var food in foods) {
      if (grouped[food.categories] == null) {
        grouped[food.categories!] = [];
      }
      grouped[food.categories]!.add(food);
    }
    return grouped;
  }

  void addFoodEntry(String date, Product food, int grams, String time){

    // hive cant store objects to encode to json string
    var serialisedFood = food.toJson();

    // serialisedFood will later be parsed back into a Product object
    // in the fromJson parse, only fields of Product are valid
    // here i high-jack this suitably named field of Product
    // to store the user's input grams
    serialisedFood['quantity'] = grams.toString();

    // similar story with this field used to store an id that identifies
    // this entry within the local database.
    // relative position is inadequate as that is lost upon sorting/grouping
    // via time
    serialisedFood['stores'] = generateId();

    // i am really running out of suitable nomers
    serialisedFood['categories'] = time;

    // get currently held data
    var serialisedFoodList = readList(date);

    // add new food to list
    serialisedFoodList.add(serialisedFood);

    // update database with updated list
    _foodEntriesBox.put(date, serialisedFoodList);
  }

  void deleteFoodEntry(String date, String id) {

    var serialisedFoodList = readList(date);

    for (int index = 0; index < serialisedFoodList.length; index++) {
      if (serialisedFoodList[index]['stores'] == id) {
        serialisedFoodList.removeAt(index);
        break;
      }
    }

    _foodEntriesBox.put(date, serialisedFoodList);
  }

  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String generateId() => String.fromCharCodes(Iterable.generate(
      24, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  /*
  * PREFERENCES METHODS
  * */

  Map getPreferences(String date) {
    
    // sort dates
    List keys = (_preferencesBox.keys.toList());
    keys.sort((a,b) {
       return DateTime.parse(a).compareTo(DateTime.parse(b));
    });

    // find the preferences record behind the selected date
    // (if selected date is before any preferences records use empty string
    // which will default to empty map as below)
    var nearestDateBelow = '';
    for (final keysDate in keys) {
      if (DateTime.parse(keysDate).isBefore(DateTime.parse(date))) {
        nearestDateBelow = keysDate;
        break;
      }
    }

    // get preferences for mostRecentDate, if no preferences use 0
    Map preferencesForMostRecentDate = _preferencesBox.get(nearestDateBelow,
      defaultValue: {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0
      }
    );

    // get preferences for selected date, if none there, (i.e. if in future)
    // use the values from most recent date
    Map preferencesForDate = _preferencesBox.get(date,
        defaultValue: preferencesForMostRecentDate
    );

    return preferencesForDate;
  }

  void updatePreferences(String date, Map updatedPreferences) {

    // preferences tied to a date
    // edit preferences button only appears on today or future dates

    _preferencesBox.put(date, updatedPreferences);
  }
}