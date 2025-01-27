import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class LocalDatabase {

  // reference the hive box
  final _foodEntriesBox = Hive.box('userFoodEntries');

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

  List<Product> getFoodEntriesForDate(String date){

    List<Product> dataToReturn = [];

    // decode json string back into Product
    for (final serialisedFood in readList(date)) {
      dataToReturn.add(Product.fromJson(serialisedFood));
    }

    return dataToReturn;
  }

  void addFoodEntry(String date, Product food, int grams){

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
}