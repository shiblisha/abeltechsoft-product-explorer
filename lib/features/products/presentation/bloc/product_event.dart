import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page of products. Set [refresh] to true to reload the list.
class LoadProducts extends ProductEvent {
  const LoadProducts({this.refresh = false});

  final bool refresh;

  @override
  List<Object?> get props => [refresh];
}

/// Loads the next page and appends it to the products already in state.
class LoadMoreProducts extends ProductEvent {
  const LoadMoreProducts();
}

/// Loads one product by its ID for the product details screen.
class LoadProductDetails extends ProductEvent {
  const LoadProductDetails(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}
