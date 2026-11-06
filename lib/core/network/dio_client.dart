import 'package:dio/dio.dart';

class DioClient {
  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: 'https://dummyjson.com',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: const {'Accept': 'application/json'},
        ),
      );

  final Dio dio;
}
