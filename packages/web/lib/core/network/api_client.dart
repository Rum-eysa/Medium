import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response;
import '../config/app_config.dart';
import '../services/secure_storage_service.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  late dio.Dio _dio;
  // ignore: unused_field
  final _storage = SecureStorageService();

  ApiClient._internal() {
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.requestTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.requestTimeout),
      ),
    );

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }

  Future<dio.Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<dio.Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<dio.Response<T>> patch<T>(String path, {dynamic data}) async {
    return _dio.patch(path, data: data);
  }

  Future<dio.Response<T>> delete<T>(String path) async {
    return _dio.delete(path);
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class AuthInterceptor extends dio.Interceptor {
  final _storage = SecureStorageService();

  @override
  Future<void> onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(StorageKeys.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    dio.DioException err,
    dio.ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(StorageKeys.refreshToken);
      if (refreshToken != null) {
        try {
          final response = await dio.Dio().post(
            '${AppConfig.apiBaseUrl}${ApiEndpoints.refresh}',
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            final data = response.data['data'];
            await _storage.write(StorageKeys.accessToken, data['access_token']);
            await _storage.write(
              StorageKeys.refreshToken,
              data['refresh_token'],
            );

            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer ${data['access_token']}';

            final newResponse = await dio.Dio().request(
              options.path,
              options: dio.Options(
                method: options.method,
                headers: options.headers,
              ),
              data: options.data,
            );

            return handler.resolve(newResponse);
          }
        } catch (e) {
          await _storage.deleteAll();
          Get.offAllNamed('/login');
        }
      }
    }
    return handler.next(err);
  }
}

class ErrorInterceptor extends dio.Interceptor {
  @override
  Future<void> onError(
    dio.DioException err,
    dio.ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      final errorMsg = _getErrorMessage(err);
      Get.snackbar(
        'Hata',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return handler.next(err);
  }

  String _getErrorMessage(dio.DioException error) {
    if (error.response?.data is Map) {
      final data = error.response!.data as Map;
      return data['error']?['message'] ?? 'Bilinmeyen hata';
    }
    return error.message ?? 'Bağlantı hatası';
  }
}
