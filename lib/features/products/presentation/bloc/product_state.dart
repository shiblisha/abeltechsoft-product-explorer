import 'package:equatable/equatable.dart';

import '../../data/models/product.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.total = 0,
    this.isLoadingMore = false,
    this.errorMessage,
    this.paginationError,
  });

  final ProductStatus status;
  final List<Product> products;
  final int total;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? paginationError;

  bool get hasReachedMax => products.length >= total && total > 0;

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    int? total,
    bool? isLoadingMore,
    String? errorMessage,
    String? paginationError,
    bool clearErrorMessage = false,
    bool clearPaginationError = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      paginationError: clearPaginationError
          ? null
          : paginationError ?? this.paginationError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    total,
    isLoadingMore,
    errorMessage,
    paginationError,
  ];
}
