import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class LocalDatabase {

  // reference the hive box
  final _foodEntriesBox = Hive.box('userFoodEntries');
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

  int getPreferences(String preference) {
    switch(preference) {
      case 'calories':
        return _preferencesBox.get('DESIRED_CALORIES') ?? 0;
      case 'protein':
        return _preferencesBox.get('DESIRED_PROTEIN') ?? 0;
      case 'carb':
        return _preferencesBox.get('DESIRED_CARB') ?? 0;
      case 'fat':
        return _preferencesBox.get('DESIRED_FAT') ?? 0;
      default:
        return 0;
    }
  }

  void updatePreferences(String preference, int value) {
    switch(preference) {
      case 'calories':
        _preferencesBox.put('DESIRED_CALORIES', value);
      case 'protein':
        _preferencesBox.put('DESIRED_PROTEIN', value);
      case 'carb':
        _preferencesBox.put('DESIRED_CARB', value);
      case 'fat':
        _preferencesBox.put('DESIRED_FAT', value);
    }
  }
}