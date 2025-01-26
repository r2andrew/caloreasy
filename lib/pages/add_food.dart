import 'package:caloreasy/components/returned_food_tile.dart';
import 'package:caloreasy/database/local_database.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class AddFoodPage extends StatefulWidget {

  final String selectedDate;

  AddFoodPage({super.key, required this.selectedDate});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {

  final _TextController = TextEditingController();

  LocalDatabase db = LocalDatabase();

  // OpenFoodAPI creds
  final User? user = User(
      userId: 'r2andrew',
      password: 'caloreasy'
  );

  List<Product?> returnedProducts = [];
  bool loading = false;

  void getProductByBarcode(String barcode) async {

    setState(() {
      loading = true;
      returnedProducts = [];
    });

    OpenFoodAPIConfiguration.userAgent = UserAgent(
        name: 'caloreasy'
    );

    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      language: OpenFoodFactsLanguage.ENGLISH,
      fields: [ProductField.ALL],
      version: ProductQueryVersion.v3,
    );
    final ProductResultV3 result =
          await OpenFoodAPIClient.getProductV3(configuration);

    if (result.status == ProductResultV3.statusSuccess) {
      setState(() {
        returnedProducts.add(result.product);
        loading = false;
      });
    } else {
      throw Exception('product not found');
    }
  }

  void getProductsBySearch(String searchTerm) async {

    setState(() {
      loading = true;
      returnedProducts = [];
    });

    OpenFoodAPIConfiguration.userAgent = UserAgent(
        name: 'caloreasy'
    );

    final ProductSearchQueryConfiguration configuration = ProductSearchQueryConfiguration(
      parametersList: <Parameter>[
        SearchTerms(terms: [searchTerm])
      ],
      version: ProductQueryVersion.v3,
    );
    final SearchResult result =
        await OpenFoodAPIClient.searchProducts(user, configuration);
    setState(() {
      for (var i = 0; i < (result.products?.length ?? 0); i++) {
        returnedProducts.add(result.products?[i]);
      }
      loading = false;
    });
  }

  void saveFood (Product food) {
    db.addFoodEntry(widget.selectedDate, food);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Add Food')),
        backgroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _TextController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search'
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    MaterialButton(
                        color: Colors.grey[800],
                        onPressed: () => getProductByBarcode('0048151623426'),
                        child: Text('Get Product Info by Barcode'),
                    ),
                    MaterialButton(
                      color: Colors.grey[800],
                      // TODO: check what happens when empty search term
                      onPressed: () => getProductsBySearch(_TextController.text ?? ''),
                      child: Text('Get Product Info by Search'),
                    ),
                  ],
                ),
              ),
            ),
            Builder(
                builder: (context) {
                  if (loading == true) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: returnedProducts.length,
                        itemBuilder: (context, index) {
                          return ReturnedFoodTile(
                              food: returnedProducts[index]!,
                              saveFunction: saveFood
                          );
                        }
                    );
                  }
                }
            )
          ],
        ),
      ),
    );
  }
}
