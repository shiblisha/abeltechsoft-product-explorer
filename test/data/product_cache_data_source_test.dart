import 'package:abeltechsoft_test/features/products/data/datasources/product_cache_data_source.dart';
import 'package:abeltechsoft_test/features/products/data/models/product_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/product_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late ProductCacheDataSource cache;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    cache = ProductCacheDataSource(preferences);
  });

  test('stores and reads a product page', () async {
    final product = makeProduct();
    const response = ProductResponse(
      products: [],
      total: 0,
      skip: 0,
      limit: 20,
    );
    final populated = ProductResponse(
      products: [product],
      total: 1,
      skip: 0,
      limit: 20,
    );

    expect(response.products, isEmpty);
    await cache.saveProducts(populated);
    final result = cache.getProducts(limit: 20, skip: 0);

    expect(result, isNotNull);
    expect(result!.products.single.title, 'Test product');
    expect(result.total, 1);
  });

  test('stores and reads product details', () async {
    final product = makeProduct(id: 42);
    await cache.saveProduct(product);

    final restored = cache.getProduct(42);

    expect(restored, isNotNull);
    expect(restored!.id, 42);
    expect(restored.title, product.title);
  });

  test('returns null when cache entry does not exist', () {
    expect(cache.getProducts(), isNull);
    expect(cache.getProduct(999), isNull);
  });
}
