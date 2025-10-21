import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constans/api_constants.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  ApiClient({Dio? dio})
      : dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: ApiConstants.connectionTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )) {
    // Tambahkan interceptor untuk token
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Tambahkan token ke header jika ada
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: 'auth_token');
          }
          return handler.next(error);
        },
      ),
    );
    
    // Logging interceptor (opsional)
    this.dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    return await dio.post(endpoint, data: data);
  }

  Future<Response> get(String endpoint) async {
    return await dio.get(endpoint);
  }
  
  Future<Response> put(String endpoint, Map<String, dynamic> data) async {
    return await dio.put(endpoint, data: data);
  }
  
  Future<Response> delete(String endpoint) async {
    return await dio.delete(endpoint);
  }
}
