import 'dart:convert';

Map<String, dynamic> nutriments = {'salt_serving': 1.1,
  'salt_100g': 1.1,
  'sodium_serving': 0.44,
  'sodium_100g': 0.44,
  'fiber_serving': 3.5,
  'fiber_100g': 3.5,
  'sugars_serving': 1.4,
  'sugars_100g': 1.4,
  'fat_serving': 31.0,
  'fat_100g': 31.0,
  'saturated-fat_serving': 6.6,
  'saturated-fat_100g': 6.6,
  'proteins_serving': 5.9,
  'proteins_100g': 5.9,
  'energy-kcal_serving': 534.0,
  'energy-kcal_100g': 534.0,
  'energy-kj_serving': 2220.0,
  'energy-kj_100g': 2218.0,
  'carbohydrates_serving': 56.0,
  'carbohydrates_100g': 56.0};

var product =
{
  'product_name': 'Pringles Original',
  'nutriments': nutriments
};

var successResult =
[{
  'products' : [product],
  'count' : 1
}];

var failResult =
[{
  'products' : [],
  'count' : 0
}];

var successResultTyped =
(jsonDecode(jsonEncode(successResult)) as List)
    .cast<Map<String, dynamic>>();

var failResultTyped =
(jsonDecode(jsonEncode(failResult)) as List)
    .cast<Map<String, dynamic>>();