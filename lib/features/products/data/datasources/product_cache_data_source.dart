import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/product_response.dart';

/// Small persistent cache for the assignment's previously fetched products.
/// Each pagination page is cached separately, and product details by product ID.
class ProductCacheDataSource {
  ProductCacheDataSource(this._preferences);

  final SharedPreferences _preferences;

  String _pageKey(int limit, int skip) => 'products_page_${limit}_$skip';
  String _detailKey(int id) => 'product_detail_$id';

  Future<void> saveProducts(ProductResponse response) async {
    final payload = {
      'products': response.products.map((product) => product.toJson()).toList(),
      'total': response.total,
      'skip': response.skip,
      'limit': response.limit,
    };
    await _preferences.setString(
      _pageKey(response.limit, response.skip),
      jsonEncode(payload),
    );
  }

  ProductResponse? getProducts({int limit = 20, int skip = 0}) {
    final raw = _preferences.getString(_pageKey(limit, skip));
    if (raw == null) return null;
    try {
      return ProductResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> saveProduct(Product product) async {
    await _preferences.setString(
      _detailKey(product.id),
      jsonEncode(product.toJson()),
    );
  }

  Product? getProduct(int id) {
    final raw = _preferences.getString(_detailKey(id));
    if (raw == null) return null;
    try {
      return Product.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
