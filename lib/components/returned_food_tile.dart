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

  // TODO: change this to a stateless widget
  // add -> added onPressed

  @override
  Widget build(BuildContext context) {
    return Center(child: Row(
      children: [
        Text(food.productName!),
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
