import 'package:abeltechsoft_test/features/products/data/models/product_response.dart';
import 'package:abeltechsoft_test/features/products/domain/repositories/product_repository.dart';
import 'package:abeltechsoft_test/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  testWidgets('shows product explorer and empty state from mocked repository', (
    tester,
  ) async {
    final repository = MockProductRepository();
    when(() => repository.getProducts(limit: 20, skip: 0)).thenAnswer(
      (_) async =>
          const ProductResponse(products: [], total: 0, skip: 0, limit: 20),
    );

    await tester.pumpWidget(ProductExplorerApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('PRODUCT EXPLORER'), findsOneWidget);
    expect(find.text('Find your next favorite'), findsOneWidget);
    expect(find.text('Discover products'), findsOneWidget);
    expect(find.text('No matching products'), findsOneWidget);
  });
}
