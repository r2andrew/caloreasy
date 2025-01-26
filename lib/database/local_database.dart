import 'dart:convert';
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

    // get currently held data
    var serialisedFoodList = readList(date);

    // add new food to list
    serialisedFoodList.add(serialisedFood);

    // update database with updated list
    _foodEntriesBox.put(date, serialisedFoodList);
  }

  void deleteFoodEntry(String date, int index) {
    var serialisedFoodList = readList(date);

    serialisedFoodList.removeAt(index);

    _foodEntriesBox.put(date, serialisedFoodList);
  }
}