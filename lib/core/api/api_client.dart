import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/error_handler.dart';

class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String baseUrl = 'http://localhost:8888';

  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print('[DIO] ${object.toString()}'),
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('[API] 🚀 REQUEST: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('[API] ✅ RESPONSE [${response.statusCode}]: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          print('[API] ❌ ERROR [${error.response?.statusCode}]: ${error.requestOptions.path}');
          print('[API] Error message: ${error.message}');

          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            try {
              final refreshToken = await _secureStorage.read(key: 'refresh_token');
              if (refreshToken != null) {
                print('[API] 🔄 Attempting token refresh');
                final response = await _dio.post(
                  '/auth/refresh',
                  data: {'refresh': refreshToken},
                );

                if (response.statusCode == 201) {
                  final newAccessToken = response.data['access'];
                  await _secureStorage.write(key: 'access_token', value: newAccessToken);
                  print('[API] 🔑 Token refreshed successfully');

                  // Retry the original request
                  final opts = Options(
                    method: error.requestOptions.method,
                    headers: {
                      ...error.requestOptions.headers,
                      'Authorization': 'Bearer $newAccessToken',
                    },
                  );

                  print('[API] 🔄 Retrying original request: ${error.requestOptions.path}');
                  final cloneReq = await _dio.request(
                    error.requestOptions.path,
                    options: opts,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  );

                  return handler.resolve(cloneReq);
                }
              }
            } catch (e) {
              // If refresh fails, clear tokens and redirect to login
              print('[API] ❌ Token refresh failed: $e');
              await _secureStorage.deleteAll();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
