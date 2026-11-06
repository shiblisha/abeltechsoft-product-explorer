import 'package:abeltechsoft_test/features/products/data/models/product.dart';

Product makeProduct({int id = 1, String title = 'Test product'}) {
  return Product(
    id: id,
    title: title,
    description: 'A test description',
    category: 'beauty',
    price: 10,
    discountPercentage: 10,
    rating: 4.5,
    stock: 12,
    tags: const ['test'],
    brand: 'Test brand',
    sku: 'TEST-001',
    weight: 1,
    warrantyInformation: '1 year warranty',
    shippingInformation: 'Ships in 1-2 business days',
    availabilityStatus: 'In Stock',
    returnPolicy: '30 days return',
    minimumOrderQuantity: 1,
    thumbnail: 'https://example.com/image.png',
    images: const ['https://example.com/image.png'],
    dimensions: const {'width': 10, 'height': 5, 'depth': 2},
    reviews: const [],
  );
}
