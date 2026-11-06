import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';
import 'features/products/data/datasources/product_cache_data_source.dart';
import 'features/products/data/datasources/product_remote_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/products/presentation/bloc/product_detail_bloc.dart';
import 'features/products/presentation/bloc/product_event.dart';
import 'features/products/presentation/pages/product_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final dioClient = DioClient();
  final remoteDataSource = ProductRemoteDataSource(dioClient);
  final cacheDataSource = ProductCacheDataSource(preferences);
  final ProductRepository repository = ProductRepositoryImpl(
    remoteDataSource,
    cacheDataSource: cacheDataSource,
  );

  runApp(ProductExplorerApp(repository: repository));
}

class ProductExplorerApp extends StatelessWidget {
  const ProductExplorerApp({required this.repository, super.key});

  final ProductRepository repository;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF315C55);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProductRepository>.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ProductBloc(repository)..add(const LoadProducts()),
          ),
          BlocProvider(create: (_) => ProductDetailBloc(repository)),
        ],
        child: MaterialApp(
          title: 'Product Explorer',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.light,
              surface: const Color(0xFFF8F9F7),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9F7),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF8F9F7),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFE9ECE8)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              hintStyle: const TextStyle(color: Color(0xFF929A95)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E9E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E9E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: seed, width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          home: const ProductListPage(),
        ),
      ),
    );
  }
}
