import 'package:abeltechsoft_test/features/products/data/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/product_fixtures.dart';

void main() {
  group('Product model', () {
    test('parses API JSON fields', () {
      final product = Product.fromJson(makeProduct().toJson());

      expect(product.id, 1);
      expect(product.title, 'Test product');
      expect(product.price, 10);
      expect(product.rating, 4.5);
      expect(product.tags, ['test']);
      expect(product.dimensions['width'], 10);
    });

    test('serializes and restores product for local cache', () {
      final original = makeProduct(id: 7, title: 'Cached item');
      final restored = Product.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.images, original.images);
      expect(restored.reviews, original.reviews);
    });

    test('uses safe defaults for missing optional API values', () {
      final product = Product.fromJson({'id': 2, 'title': 'Minimal'});

      expect(product.id, 2);
      expect(product.title, 'Minimal');
      expect(product.price, 0);
      expect(product.tags, isEmpty);
      expect(product.images, isEmpty);
      expect(product.brand, isNull);
    });
  });
}
