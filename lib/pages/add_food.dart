import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'dart:async';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {



  Future<Product?> getProduct(String barcode) async {

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
      return result.product;
    } else {
      throw Exception('product not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Add Food')),
        backgroundColor: Colors.black,
      ),

      body: FutureBuilder(
          future: getProduct('0048151623426'),
          builder: (BuildContext context, AsyncSnapshot<Product?> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return Text(snapshot.data?.productName
                      ?? 'ERROR: api returned unexpected data shape');
                }

              default: return Text('ERROR: unhandled state');
            }
          }
      ),
    );
  }
}
