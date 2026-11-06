import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc(this._repository) : super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
  }

  static const int _pageSize = 20;
  final ProductRepository _repository;

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state.status == ProductStatus.loading && !event.refresh) return;

    emit(
      state.copyWith(
        status: ProductStatus.loading,
        products: event.refresh ? [] : state.products,
        total: event.refresh ? 0 : state.total,
        isLoadingMore: false,
        clearErrorMessage: true,
        clearPaginationError: true,
      ),
    );

    try {
      final response = await _repository.getProducts(limit: _pageSize, skip: 0);
      emit(
        ProductState(
          status: ProductStatus.success,
          products: response.products,
          total: response.total,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: _readableError(error),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state.status != ProductStatus.success ||
        state.isLoadingMore ||
        state.hasReachedMax ||
        state.products.isEmpty) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearPaginationError: true));

    try {
      final response = await _repository.getProducts(
        limit: _pageSize,
        skip: state.products.length,
      );
      final updatedProducts = [...state.products, ...response.products];
      emit(
        state.copyWith(
          status: ProductStatus.success,
          products: updatedProducts,
          total: response.total,
          isLoadingMore: false,
          clearPaginationError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          paginationError: _readableError(error),
        ),
      );
    }
  }

  String _readableError(Object error) {
    if (error is DioException) {
      if (error.response != null) {
        return 'The server returned an error. Please try again.';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'The request timed out. Check your connection and try again.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection. Please check your network and retry.';
      }
    }
    return 'Something went wrong while loading products. Please try again.';
  }
}
