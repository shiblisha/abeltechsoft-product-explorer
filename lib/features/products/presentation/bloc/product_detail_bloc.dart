import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductEvent, ProductDetailState> {
  ProductDetailBloc(this._repository) : super(const ProductDetailState()) {
    on<LoadProductDetails>(_onLoadProductDetails);
  }

  final ProductRepository _repository;

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(const ProductDetailState(status: ProductStatus.loading));

    try {
      final product = await _repository.getProductById(event.productId);
      emit(ProductDetailState(status: ProductStatus.success, product: product));
    } catch (error) {
      emit(
        ProductDetailState(
          status: ProductStatus.failure,
          errorMessage: _readableError(error),
        ),
      );
    }
  }

  String _readableError(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection. Please check your network and retry.';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'The request timed out. Please try again.';
      }
    }
    return 'Unable to load this product. Please try again.';
  }
}
