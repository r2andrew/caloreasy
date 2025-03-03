import 'dart:convert';
import 'dart:math';
import 'package:caloreasy/helpers/exercise.dart';
import 'package:hive/hive.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class LocalDatabase {

  // reference the hive box

  // <Map<String, dynamic>>
  // date : product[]
  final _foodEntriesBox = Hive.box('userFoodEntries');

  // Map
  // date : {}
  final _preferencesBox = Hive.box('userPreferences');

  final _notificationsBox = Hive.box('notifications');

  // Map
  // date : exercise[]
  final _exerciseEntriesBox = Hive.box('userExerciseEntries');

  // double
  final _weightEntriesBox = Hive.box('userWeightEntries');

  /*
  * FOOD METHODS
  * */

  // Hive can't store objects, they must be serialised into JSON string
  // except it can barely handle that even
  // It converts List<Map<String, dynamic>> into List<dynamic>
  // fromJson methods require the correct type
  List<Map<String, dynamic>> readList (String date, dynamic box) {
    var dynamicList = box.get(date, defaultValue: []);
    var fixedType =
        (jsonDecode(jsonEncode(dynamicList)) as List)
            .cast<Map<String, dynamic>>();

    return fixedType;
  }

  bool foodEntriesToday (String date) {
    return readList(date, _foodEntriesBox).isNotEmpty;
  }

  Map<String, List<Product>> getFoodEntriesForDate(String date) {

    List<Product> foods = [];

    // decode json string back into Product
    for (final serialisedFood in readList(date, _foodEntriesBox)) {
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
    var serialisedFoodList = readList(date, _foodEntriesBox);

    // add new food to list
    serialisedFoodList.add(serialisedFood);

    // update database with updated list
    _foodEntriesBox.put(date, serialisedFoodList);
  }

  void deleteFoodEntry(String date, String id) {

    var serialisedFoodList = readList(date, _foodEntriesBox);

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


  Map calcNutrientsConsumedForDay(selectedDate) {

    int caloriesConsumed = 0;
    int caloriesBurned = 0;
    int proteinConsumed = 0;
    int carbsConsumed = 0;
    int fatConsumed = 0;

    var times = ['Morning', 'Afternoon', 'Evening'];

    for (var time in times) {
      var foodList = getFoodEntriesForDate(selectedDate)[time] ?? [];
      for (var food in foodList) {
        caloriesConsumed +=
            (((food.nutriments!.getComputedKJ(PerSize.oneHundredGrams) ?? 0) *
                (int.parse(food.quantity!) / 100)) * 0.239 ).toInt();
        proteinConsumed +=
            ((food.nutriments!.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0) *
                (int.parse(food.quantity!) / 100)).toInt();
        carbsConsumed +=
            ((food.nutriments!.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ?? 0) *
                (int.parse(food.quantity!) / 100)).toInt();
        fatConsumed +=
            ((food.nutriments!.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0) *
                (int.parse(food.quantity!) / 100)).toInt();
      }
    }
    var exerciseList = getExerciseEntriesForDate(selectedDate);
    for (var exercise in exerciseList) {
      caloriesBurned += exercise.calBurned;
    }

    return {
      'caloriesConsumed' : caloriesConsumed,
      'caloriesBurned' : caloriesBurned,
      'proteinConsumed' : proteinConsumed,
      'carbsConsumed' : carbsConsumed,
      'fatConsumed' : fatConsumed
    };
  }

  /*
  * EXERCISES METHODS
  * */
  List<Exercise> getExerciseEntriesForDate (String date) {
    List entries = readList(date, _exerciseEntriesBox);

    List<Exercise> updatedEntries = entries.map((e) =>
        Exercise.fromJson(e)
    ).toList();

    return updatedEntries;
  }

  void addExerciseEntry(String date, String name, int minutes) {
    var exercise = Exercise(name, minutes);
    var entry = exercise.toJson();

    List entries = _exerciseEntriesBox.get(date, defaultValue: []);

    entries.add(entry);

    _exerciseEntriesBox.put(date, entries);
  }

  // unlike food, exercises are always presented with their original indexing
  // so using relative indexing is fine
  void deleteExerciseEntry(String date, int index) {
    List entries = _exerciseEntriesBox.get(date, defaultValue: []);
    entries.removeAt(index);
    _exerciseEntriesBox.put(date, entries);
  }

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

  /*
  * PREFERENCES METHODS
  * */

  bool getNotificationsStatus() {
    return _notificationsBox.get('status') ?? false;
  }

  void toggleNotificationsStatus() {
    bool status = _notificationsBox.get('status') ?? false;
    _notificationsBox.put('status', !status);
  }

  /*
  * WEIGHT METHODS
  * */

  double getWeightForDate(String date) {
    return _weightEntriesBox.get(date, defaultValue: 0.0);
  }

  void storeWeightForDate(String date, double weight) {
    _weightEntriesBox.put(date, weight);
  }

}