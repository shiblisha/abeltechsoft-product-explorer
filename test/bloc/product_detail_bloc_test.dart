import 'package:abeltechsoft_test/features/products/domain/repositories/product_repository.dart';
import 'package:abeltechsoft_test/features/products/presentation/bloc/product_detail_bloc.dart';
import 'package:abeltechsoft_test/features/products/presentation/bloc/product_detail_state.dart';
import 'package:abeltechsoft_test/features/products/presentation/bloc/product_event.dart';
import 'package:abeltechsoft_test/features/products/presentation/bloc/product_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/product_fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;

  setUp(() => repository = MockProductRepository());

  blocTest<ProductDetailBloc, ProductDetailState>(
    'loads product details successfully',
    build: () {
      when(() => repository.getProductById(1))
          .thenAnswer((_) async => makeProduct());
      return ProductDetailBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadProductDetails(1)),
    expect: () => [
      isA<ProductDetailState>().having(
        (state) => state.status,
        'status',
        ProductStatus.loading,
      ),
      isA<ProductDetailState>()
          .having((state) => state.status, 'status', ProductStatus.success)
          .having((state) => state.product?.id, 'product id', 1),
    ],
  );

  blocTest<ProductDetailBloc, ProductDetailState>(
    'emits failure when details cannot be loaded',
    build: () {
      when(() => repository.getProductById(1)).thenThrow(Exception('offline'));
      return ProductDetailBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadProductDetails(1)),
    expect: () => [
      isA<ProductDetailState>().having(
        (state) => state.status,
        'status',
        ProductStatus.loading,
      ),
      isA<ProductDetailState>()
          .having((state) => state.status, 'status', ProductStatus.failure)
          .having((state) => state.errorMessage, 'error', isNotNull),
    ],
  );
}
