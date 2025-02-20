import 'package:openfoodfacts/openfoodfacts.dart';

class customFoodAPIClient {

  // OpenFoodAPI creds
  static const User user = User(
      userId: 'r2andrew',
      password: 'caloreasy'
  );

  const customFoodAPIClient();

  Future<SearchResult> searchProducts(String searchTerm) async {

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

    return OpenFoodAPIClient.searchProducts(user, configuration);
  }

}