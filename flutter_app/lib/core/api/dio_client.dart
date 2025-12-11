import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constans.dart';

class DioClient {
  final Dio _dio;
  final Logger _logger = Logger();

  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    // Menambahkan Interceptor untuk logging request/response
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i("Request: ${options.method} ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d("Response: ${response.statusCode} ${response.data}");
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          _logger.e("Error: ${e.response?.statusCode} ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
