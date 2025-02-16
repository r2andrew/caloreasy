import 'package:openfoodfacts/openfoodfacts.dart';

class FoodService {

  Function loadResults;

  // OpenFoodAPI creds
  final User? user = User(
      userId: 'r2andrew',
      password: 'caloreasy'
  );

  FoodService(void Function(bool loaded, String error, [List<Product?> products]) this.loadResults);

  void getProductsBySearch(String searchTerm) async {

    loadResults(false, '');

    OpenFoodAPIConfiguration.userAgent = UserAgent(
        name: 'caloreasy'
    );
    OpenFoodAPIConfiguration.globalLanguages =
      <OpenFoodFactsLanguage>[OpenFoodFactsLanguage.ENGLISH];
    OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.UNITED_KINGDOM;

    final ProductSearchQueryConfiguration configuration = ProductSearchQueryConfiguration(
        parametersList: <Parameter>[
          SearchTerms(terms: [searchTerm])
        ],
        version: ProductQueryVersion.v3,
        fields: [
          ProductField.NAME,
          ProductField.NUTRIMENTS
        ]
    );
    final SearchResult result =
    await OpenFoodAPIClient.searchProducts(user, configuration);

    List<Product?> returnedProducts = [];

    if (result.count! > 0) {
      for (var i = 0; i < (result.products?.length ?? 0); i++) {
      // ignore results with no name
        if (result.products?[i].productName != '') {
          returnedProducts.add(result.products?[i]);
        }
      }
      loadResults(true, '', returnedProducts);
    } else {
      loadResults(true, 'No items found');
    }
  }

  void getProductByBarcode(String barcode) async {

    loadResults(false, '');

    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'caloreasy'
    );
    OpenFoodAPIConfiguration.globalLanguages =
      <OpenFoodFactsLanguage>[OpenFoodFactsLanguage.ENGLISH];
    OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.UNITED_KINGDOM;

    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      language: OpenFoodFactsLanguage.ENGLISH,
      fields: [ProductField.ALL],
      version: ProductQueryVersion.v3,
    );

    final ProductResultV3 result =
    await OpenFoodAPIClient.getProductV3(configuration);

    if (result.status == ProductResultV3.statusSuccess) {
      loadResults(true, '', [result.product]);
    } else {
      loadResults(true, 'No items found');
    }
  }
}