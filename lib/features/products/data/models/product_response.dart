import 'product.dart';

class ProductResponse {
  const ProductResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? const [];

    return ProductResponse(
      products: rawProducts
          .whereType<Map>()
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }
}
