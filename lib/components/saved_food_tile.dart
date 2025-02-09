import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class SavedFoodTile extends StatelessWidget {

  final Product food;
  Function(BuildContext)? deleteFunction;
  DateTime selectedDate;

  SavedFoodTile({
    super.key,
    required this.food,
    required this.deleteFunction,
    required this.selectedDate,
  });

  DateTime todaysDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: selectedDate == todaysDate ? ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red,
            )
          ]
      ) : null,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.grey[800],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(food.productName!
            ),
            Row(
              children: [
                Icon(Icons.energy_savings_leaf),
                Text('\t${(food.nutriments!.getComputedKJ(PerSize.oneHundredGrams) ?? 0 *
                    (int.parse(food.quantity!) / 100)).toInt()}')
              ],
            ),
          ],
        ),
      ),
    );
  }
}
