import 'package:abeltechsoft_test/features/products/data/models/product_response.dart';
import 'package:abeltechsoft_test/features/products/domain/repositories/product_repository.dart';
import 'package:abeltechsoft_test/features/products/presentation/bloc/product_bloc.dart';
import 'package:abeltechsoft_test/features/products/presentation/bloc/product_event.dart';
import 'package:abeltechsoft_test/features/products/presentation/bloc/product_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/product_fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
  });

  blocTest<ProductBloc, ProductState>(
    'emits loading then success when products load',
    build: () {
      when(() => repository.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => ProductResponse(
          products: [makeProduct()],
          total: 1,
          skip: 0,
          limit: 20,
        ),
      );
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadProducts()),
    expect: () => [
      isA<ProductState>().having(
        (state) => state.status,
        'status',
        ProductStatus.loading,
      ),
      isA<ProductState>()
          .having((state) => state.status, 'status', ProductStatus.success)
          .having((state) => state.products.length, 'products length', 1),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'emits failure when repository throws',
    build: () {
      when(() => repository.getProducts(limit: 20, skip: 0))
          .thenThrow(Exception('offline'));
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadProducts()),
    expect: () => [
      isA<ProductState>().having(
        (state) => state.status,
        'status',
        ProductStatus.loading,
      ),
      isA<ProductState>()
          .having((state) => state.status, 'status', ProductStatus.failure)
          .having((state) => state.errorMessage, 'error', isNotNull),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'appends next page on pagination',
    build: () {
      when(() => repository.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => ProductResponse(
          products: [makeProduct(id: 1)],
          total: 2,
          skip: 0,
          limit: 20,
        ),
      );
      when(() => repository.getProducts(limit: 20, skip: 1)).thenAnswer(
        (_) async => ProductResponse(
          products: [makeProduct(id: 2)],
          total: 2,
          skip: 1,
          limit: 20,
        ),
      );
      return ProductBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const LoadProducts());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const LoadMoreProducts());
    },
    wait: const Duration(milliseconds: 30),
    expect: () => [
      isA<ProductState>().having(
        (state) => state.status,
        'status',
        ProductStatus.loading,
      ),
      isA<ProductState>()
          .having((state) => state.status, 'status', ProductStatus.success)
          .having((state) => state.products.length, 'products', 1),
      isA<ProductState>().having(
        (state) => state.isLoadingMore,
        'loading more',
        true,
      ),
      isA<ProductState>()
          .having((state) => state.products.length, 'products', 2)
          .having((state) => state.isLoadingMore, 'loading more', false),
    ],
  );
}
