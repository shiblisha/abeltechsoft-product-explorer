import 'package:equatable/equatable.dart';

import '../../data/models/product.dart';
import 'product_state.dart';

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductStatus.initial,
    this.product,
    this.errorMessage,
  });

  final ProductStatus status;
  final Product? product;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, product, errorMessage];
}
