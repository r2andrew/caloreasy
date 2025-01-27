import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class SavedFoodTile extends StatelessWidget {

  final Product food;
  Function(BuildContext)? deleteFunction;

  SavedFoodTile({
    super.key,
    required this.food,
    required this.deleteFunction
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Slidable(
        endActionPane: ActionPane(
            motion: StretchMotion(),
            children: [
              SlidableAction(
                onPressed: deleteFunction,
                icon: Icons.delete,
              )
            ]
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20)
          ),
          child: Row(
            children: [
              Text("Product Name:  ${food.productName!}" +
                  '\nCalories per 100g : '
                      '${food.nutriments!.getComputedKJ(PerSize.oneHundredGrams)}' +
                  '\nGrams: '
                      '${food.quantity}'
                  '\nCalories '
                      '${food.nutriments!.getComputedKJ(PerSize.oneHundredGrams)! *
                        (int.parse(food.quantity!) / 100)}'
                  '\nTime: '
                      '${food.categories}'
              )
            ],
          ),
        ),
      ),
    );
  }
}
