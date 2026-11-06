import '../../data/models/product.dart';
import '../../data/models/product_response.dart';

abstract class ProductRepository {
  Future<ProductResponse> getProducts({int limit = 20, int skip = 0});
  Future<Product> getProductById(int id);
  Future<List<String>> getCategories();
}
