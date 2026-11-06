class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.thumbnail,
    required this.images,
    required this.dimensions,
    required this.reviews,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String? brand;
  final String sku;
  final double weight;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final String thumbnail;
  final List<String> images;
  final Map<String, dynamic> dimensions;
  final List<Map<String, dynamic>> reviews;

  factory Product.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    int toInt(dynamic value) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    String toText(dynamic value) => value?.toString() ?? '';

    return Product(
      id: toInt(json['id']),
      title: toText(json['title']),
      description: toText(json['description']),
      category: toText(json['category']),
      price: toDouble(json['price']),
      discountPercentage: toDouble(json['discountPercentage']),
      rating: toDouble(json['rating']),
      stock: toInt(json['stock']),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      brand: json['brand']?.toString(),
      sku: toText(json['sku']),
      weight: toDouble(json['weight']),
      warrantyInformation: toText(json['warrantyInformation']),
      shippingInformation: toText(json['shippingInformation']),
      availabilityStatus: toText(json['availabilityStatus']),
      returnPolicy: toText(json['returnPolicy']),
      minimumOrderQuantity: toInt(json['minimumOrderQuantity']),
      thumbnail: toText(json['thumbnail']),
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      dimensions: Map<String, dynamic>.from(
        json['dimensions'] as Map? ?? const {},
      ),
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'discountPercentage': discountPercentage,
    'rating': rating,
    'stock': stock,
    'tags': tags,
    'brand': brand,
    'sku': sku,
    'weight': weight,
    'warrantyInformation': warrantyInformation,
    'shippingInformation': shippingInformation,
    'availabilityStatus': availabilityStatus,
    'returnPolicy': returnPolicy,
    'minimumOrderQuantity': minimumOrderQuantity,
    'thumbnail': thumbnail,
    'images': images,
    'dimensions': dimensions,
    'reviews': reviews,
  };
}
