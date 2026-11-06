import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product.dart';
import '../bloc/product_detail_bloc.dart';
import '../bloc/product_detail_state.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({required this.productId, super.key});

  final int productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  int _selectedImage = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductDetailBloc>().add(LoadProductDetails(widget.productId));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            if (state.status == ProductStatus.loading ||
                state.status == ProductStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ProductStatus.failure ||
                state.product == null) {
              return _DetailError(
                message:
                    state.errorMessage ?? 'Unable to load product details.',
                onRetry: () => context.read<ProductDetailBloc>().add(
                  LoadProductDetails(widget.productId),
                ),
              );
            }
            return _buildDetails(context, state.product!);
          },
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, Product product) {
    final images = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail];
    final discountedPrice =
        product.price * (1 - product.discountPercentage / 100);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFFF8F9F7),
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text(
            'Product details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh product',
              onPressed: () => context.read<ProductDetailBloc>().add(
                LoadProductDetails(widget.productId),
              ),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Gallery(
                  images: images,
                  controller: _pageController,
                  selectedIndex: _selectedImage,
                  onChanged: (index) => setState(() => _selectedImage = index),
                ),
                const SizedBox(height: 23),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.category.replaceAll('-', ' ').toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF78827B),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF2B544),
                      size: 18,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 25,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                if (product.brand != null && product.brand!.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    'Brand: ${product.brand}',
                    style: const TextStyle(color: Color(0xFF78827B)),
                  ),
                ],
                const SizedBox(height: 17),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${discountedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF315C55),
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (product.discountPercentage > 0) ...[
                      const SizedBox(width: 9),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF929B94),
                            decoration: TextDecoration.lineThrough,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Color(0xFF315C55),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 22),
                _InfoStrip(
                  stock: product.stock,
                  status: product.availabilityStatus,
                  shipping: product.shippingInformation,
                ),
                const SizedBox(height: 26),
                const _SectionTitle('Description'),
                const SizedBox(height: 9),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: Color(0xFF68736C),
                    height: 1.55,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),
                const _SectionTitle('Product information'),
                const SizedBox(height: 10),
                _InfoRow('Category', product.category.replaceAll('-', ' ')),
                _InfoRow('Brand', product.brand ?? 'Not specified'),
                _InfoRow('SKU', product.sku),
                _InfoRow('Weight', '${product.weight} g'),
                _InfoRow('Warranty', product.warrantyInformation),
                _InfoRow('Return policy', product.returnPolicy),
                _InfoRow('Minimum order', '${product.minimumOrderQuantity}'),
                if (product.dimensions.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const _SectionTitle('Dimensions'),
                  const SizedBox(height: 10),
                  ...product.dimensions.entries.map(
                    (entry) =>
                        _InfoRow(_capitalize(entry.key), '${entry.value}'),
                  ),
                ],
                if (product.tags.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const _SectionTitle('Tags'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: const Color(0xFFEAF0EB),
                            side: BorderSide.none,
                            labelStyle: const TextStyle(
                              color: Color(0xFF315C55),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (product.reviews.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  const _SectionTitle('Customer reviews'),
                  const SizedBox(height: 10),
                  ...product.reviews.take(3).map(_ReviewCard.new),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.images,
    required this.controller,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> images;
  final PageController controller;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 310,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F3EF),
            borderRadius: BorderRadius.circular(22),
          ),
          clipBehavior: Clip.antiAlias,
          child: PageView.builder(
            controller: controller,
            itemCount: images.length,
            onPageChanged: onChanged,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(22),
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.contain,
                placeholder: (_, _) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, _, _) => const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: Color(0xFF9AA39C),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 62,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (context, index) {
                final selected = index == selectedIndex;
                return GestureDetector(
                  onTap: () {
                    controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    width: 62,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3EF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.contain,
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({
    required this.stock,
    required this.status,
    required this.shipping,
  });

  final int stock;
  final String status;
  final String shipping;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0EB),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF315C55),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$stock in stock',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFF65716A),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.local_shipping_outlined,
            color: Color(0xFF315C55),
            size: 19,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              shipping,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF65716A),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 125,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF87918A), fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(this.review);

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final reviewer = review['reviewerName']?.toString() ?? 'Customer';
    final comment = review['comment']?.toString() ?? '';
    final rating = review['rating']?.toString() ?? '-';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reviewer,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFF2B544),
                size: 16,
              ),
              Text(rating, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment,
            style: const TextStyle(
              color: Color(0xFF68736C),
              height: 1.4,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: Color(0xFF87918A),
          ),
          const SizedBox(height: 14),
          const Text(
            'Product details unavailable',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF77817A)),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go back'),
          ),
        ],
      ),
    ),
  );
}
