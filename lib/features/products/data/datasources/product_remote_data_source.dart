import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/product.dart';
import '../models/product_response.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._client);

  final DioClient _client;

  Future<ProductResponse> getProducts({int limit = 20, int skip = 0}) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/products',
        queryParameters: {'limit': limit, 'skip': skip},
      );
      return ProductResponse.fromJson(response.data ?? const {});
    } on DioException {
      rethrow;
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/products/$id',
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('The API returned an empty product.');
      }
      return Product.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  Future<List<String>> getCategories() async {
    final response = await _client.dio.get<List<dynamic>>(
      '/products/category-list',
    );
    return (response.data ?? const [])
        .map((category) => category.toString())
        .toList();
  }
}
