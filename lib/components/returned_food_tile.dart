import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ReturnedFoodTile extends StatelessWidget {

  final Product food;
  final Function saveFunction;

  const ReturnedFoodTile({
    super.key,
    required this.food,
    required this.saveFunction
  });

  // TODO: change this to a stateful widget
  // add -> added onPressed

  @override
  Widget build(BuildContext context) {
    return Center(child: Row(
      children: [
        Text(
          // if null, empty string, if not null, truncate to 20 chars
            (food.productName == null) ? ''
                : (food.productName!.length <= 20) ? food.productName!
                : '${food.productName!.substring(0, 20)}...'
        ),
        MaterialButton(
          color: Colors.grey[800],
          onPressed: () => {
            saveFunction(food)
          },
          child: Text('Add'),
        )
      ],
    ));
  }
}
