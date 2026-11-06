import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 500) {
      context.read<ProductBloc>().add(const LoadMoreProducts());
    }
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      final matchesQuery =
          _query.isEmpty ||
          product.title.toLowerCase().contains(_query) ||
          product.brand?.toLowerCase().contains(_query) == true ||
          product.category.toLowerCase().contains(_query);
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            final categories = <String>{
              'All',
              ...state.products.map((product) => product.category),
            }.toList();
            final visibleProducts = _filterProducts(state.products);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(
                  const LoadProducts(refresh: true),
                );
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: _Header(
                        searchController: _searchController,
                        onSearchChanged: (value) {
                          setState(() => _query = value.trim().toLowerCase());
                        },
                      ),
                    ),
                  ),
                  if (state.status == ProductStatus.loading &&
                      state.products.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _LoadingView(),
                    )
                  else if (state.status == ProductStatus.failure &&
                      state.products.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _ErrorView(
                        message:
                            state.errorMessage ?? 'Unable to load products.',
                        onRetry: () => context.read<ProductBloc>().add(
                          const LoadProducts(),
                        ),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 48,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final selected = category == _selectedCategory;
                            return ChoiceChip(
                              label: Text(_prettyCategory(category)),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = category),
                              showCheckmark: false,
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: selected
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFFE5E9E5),
                              ),
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF59635D),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Discover products',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            Text(
                              '${visibleProducts.length} items',
                              style: const TextStyle(
                                color: Color(0xFF7B847E),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (visibleProducts.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyView(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.66,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = visibleProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      ProductDetailPage(productId: product.id),
                                ),
                              ),
                            );
                          }, childCount: visibleProducts.length),
                        ),
                      ),
                    if (state.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    if (state.paginationError != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: TextButton.icon(
                            onPressed: () => context.read<ProductBloc>().add(
                              const LoadMoreProducts(),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: Text(state.paginationError!),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _prettyCategory(String value) => value
      .split('-')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searchController,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRODUCT EXPLORER',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF78827B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Find your next favorite',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.tune_rounded, color: Color(0xFF65716A)),
          ],
        ),
        const SizedBox(height: 22),
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search products, brands...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          'Finding great products...',
          style: TextStyle(color: Color(0xFF77817A)),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
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
            'Could not load products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF77817A)),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 44, color: Color(0xFF929B94)),
          SizedBox(height: 12),
          Text(
            'No matching products',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            'Try another search or category.',
            style: TextStyle(color: Color(0xFF7B847E)),
          ),
        ],
      ),
    ),
  );
}
