import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ReturnedFoodTile extends StatefulWidget {

  final Product food;
  final bool selected;

  const ReturnedFoodTile({
    super.key,
    required this.food,
    required this.selected
  });

  @override
  State<ReturnedFoodTile> createState() => _ReturnedFoodTileState();
}

class _ReturnedFoodTileState extends State<ReturnedFoodTile> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: widget.selected ? Colors.blue : Colors.grey[800],
              borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            children: [
              Row(
                children: [

                  Center(
                    child: Text("Name:  ${
                        (widget.food.productName == null) ? ''
                                : (widget.food.productName!.length <= 30) ? widget.food.productName!
                                : '${widget.food.productName!.substring(0, 30)}...'
                          }"
                          + '\nCalories / 100g : '
                            '${widget.food.nutriments!.getComputedKJ(PerSize.oneHundredGrams)?.toInt()}'
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
    );
  }
}
