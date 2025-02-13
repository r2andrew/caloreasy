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

  LocalDatabase db = LocalDatabase();

  late FoodService foodService;

  List<Product?> returnedProducts = [];
  bool loading = false;

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
  void loadResults (bool loaded, [List<Product?>? products]) {
    if (!loaded) {
      setState(() {
        loading = true;
        selectedFoodIndex = -1;
        returnedProducts = [];
      });
    } else {
      setState(() {
        returnedProducts = products!;
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
                      MaterialButton(
                        color: Colors.grey[800],
                        onPressed: () => foodService.getProductsBySearch(_searchController.text ?? ''),
                        child: Text('Search'),
                      ),
                      MaterialButton(
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
                        child: Text('Scan'),
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
              child: ListView.builder(
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
              ),
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
                      color: Colors.blue,
                      onPressed: addValid() ? () => saveFood() : () => (),
                      child: addValid() ? Text('Add') : Icon(Icons.not_interested),
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
