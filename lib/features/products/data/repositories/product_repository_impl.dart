import '../../domain/repositories/product_repository.dart';
import '../datasources/product_cache_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product.dart';
import '../models/product_response.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remoteDataSource, {this._cacheDataSource});

  final ProductRemoteDataSource _remoteDataSource;
  final ProductCacheDataSource? _cacheDataSource;

  @override
  Future<ProductResponse> getProducts({int limit = 20, int skip = 0}) async {
    try {
      final response = await _remoteDataSource.getProducts(
        limit: limit,
        skip: skip,
      );
      await _cacheDataSource?.saveProducts(response);
      return response;
    } catch (_) {
      final cached = _cacheDataSource?.getProducts(limit: limit, skip: skip);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(int id) async {
    try {
      final product = await _remoteDataSource.getProductById(id);
      await _cacheDataSource?.saveProduct(product);
      return product;
    } catch (_) {
      final cached = _cacheDataSource?.getProduct(id);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    return _remoteDataSource.getCategories();
  }
}
