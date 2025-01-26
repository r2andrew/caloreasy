import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ReturnedFoodTile extends StatefulWidget {

  final Product food;
  final Function saveFunction;

  const ReturnedFoodTile({
    super.key,
    required this.food,
    required this.saveFunction
  });

  @override
  State<ReturnedFoodTile> createState() => _ReturnedFoodTileState();
}

class _ReturnedFoodTileState extends State<ReturnedFoodTile> {

  final _TextController = TextEditingController();

  // TODO: change this to a stateful widget
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            children: [
              Row(
                children: [

                  Text("Product Name:  ${
                      (widget.food.productName == null) ? ''
                              : (widget.food.productName!.length <= 20) ? widget.food.productName!
                              : '${widget.food.productName!.substring(0, 20)}...'
                        }"
                        + '\nCalories per 100g : '
                          '${widget.food.nutriments!.getComputedKJ(PerSize.oneHundredGrams)}'
                  ),

                ],
              ),
              Row(
                children: [

                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: _TextController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Num Grams'
                      ),
                    ),
                  ),

                  MaterialButton(
                    color: Colors.grey[800],
                    onPressed: () => {
                      widget.saveFunction(widget.food, int.parse(_TextController.text))
                    },
                    child: Text('Add'),
                  ),

                ],
              )
            ],
          ),
        ),
    );
  }
}
