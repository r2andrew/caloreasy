import 'dart:async';
import 'package:caloreasy/components/returned_food_tile.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:caloreasy/helpers/food_service.dart';
import 'package:caloreasy/pages/barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class AddFoodPage extends StatefulWidget {

  final String selectedDate;

  AddFoodPage({super.key, required this.selectedDate});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  
  String barcode = 'Scan Something!';

  final _searchController = TextEditingController();
  final _gramsController = TextEditingController();

  String selectedTime = 'Morning';

  int selectedFoodIndex = -1;

  Color addButtonColor = Colors.blue;
  String addButtonText = 'Add';

  LocalDatabase db = LocalDatabase();

  late FoodService foodService;

  List<Product?> returnedProducts = [];
  bool loading = false;
  String apiError = '';

  void saveFood () {

    db.addFoodEntry(
        widget.selectedDate,
        returnedProducts[selectedFoodIndex]!,
        int.parse(_gramsController.text),
        selectedTime
    );
  }
  // TODO: api error handling
  // callback function for food service
  void loadResults (bool loaded, String error, [List<Product?>? products]) {
    if (!loaded) {
      setState(() {
        loading = true;
        selectedFoodIndex = -1;
        returnedProducts = [];
        apiError = '';
      });
    } else if (error.isEmpty) {
      setState(() {
        returnedProducts = products!;
        loading = false;
      });
    } else {
      setState(() {
        apiError = error;
        loading = false;
      });
    }
  }
  
  bool addValid () {
    return (selectedFoodIndex >= 0 && _gramsController.text.isNotEmpty);
  }

  @override
  void initState() {
    foodService = FoodService(loadResults);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Add Food')),
        backgroundColor: Colors.black,
      ),

      body: Column(
        children: [
          Container(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0))
                        ),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[400])
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          color: Colors.grey[800],
                          onPressed: () => foodService.getProductsBySearch(_searchController.text ?? ''),
                          child: Row(
                            children: [
                              Text('Search'),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.search),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                            color: Colors.grey[800],
                            onPressed: () async {
                              final scannedBarcode =
                                await Navigator.of(context).push<Barcode>(
                                  MaterialPageRoute(
                                      builder: (context) => const BarcodeScanner(),
                                  )
                                );
                              if (scannedBarcode != null && scannedBarcode.displayValue != null) {
                                foodService.getProductByBarcode(scannedBarcode.displayValue!);
                              }
                            },
                          child: Row(
                            children: [
                              Text('Scan'),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.barcode_reader),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),


          loading == true ? Expanded(child: Container(
              color: Colors.blue.withAlpha(50),
              child: Center(child: CircularProgressIndicator(color: Colors.blue)))
          )
          : Expanded(
            child: Container(
              color: Colors.blue.withAlpha(50),
              child: apiError.isEmpty ? ListView.builder(
                  itemCount: returnedProducts.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => setState(() {
                        selectedFoodIndex = index;
                      }),
                      child: ReturnedFoodTile(
                        food: returnedProducts[index]!,
                        selected: selectedFoodIndex == index
                      ),
                    );
                  }
              ) : Row(
                children: [
                  Expanded(child: Center(child: Text(apiError))),
                ],
              )
            ),
          ),

          Container(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  
                  SizedBox(
                    width: 120,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0))
                        ),
                        hintText: 'grams',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                      controller: _gramsController,
                      onChanged: (text) {
                        // trigger a rebuild for the purposes of the add valid checker
                        setState(() {});
                      },
                    ),
                  ),

                  DropdownButton(
                      hint: Text(selectedTime),
                      value: selectedTime,
                      items: [
                        DropdownMenuItem(
                          value: 'Morning',
                          child: Text('Morning'),
                        ),
                        DropdownMenuItem(
                          value: 'Afternoon',
                          child: Text('Afternoon'),
                        ),
                        DropdownMenuItem(
                          value: 'Evening',
                          child: Text('Evening'),
                        )
                      ],
                      onChanged: (time) {
                        setState(() {
                          selectedTime = time as String;
                        });
                      }
                  ),

                  MaterialButton(
                      color: addButtonColor,
                      onPressed: () async {
                        if (addValid()) {
                          saveFood();
                          setState(() {addButtonColor=Colors.green;addButtonText='Added';});
                          Timer(Duration(seconds: 1), () {
                            setState(() {
                              addButtonColor = Colors.blue;
                              addButtonText = 'Add';
                            });
                          });
                        }
                      },
                      child: addValid() ? Text(addButtonText) : Icon(Icons.not_interested),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
