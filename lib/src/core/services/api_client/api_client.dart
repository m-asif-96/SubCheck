import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'i_api_client.dart';
import 'interceptors/api_logger.dart';
import 'models/api_error_handler.dart';
import 'models/api_response.dart';

class ApiClient implements IApiClient {
  late final Dio _dio;

  ApiClient({Dio? customDio}) {
    final baseUrl = (dotenv.isInitialized ? dotenv.env['API_BASE_URL'] : null) ??
        'https://api.subcheck.app/v1';
    _dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(ApiLogger());
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      final parsed = fromJson != null ? fromJson(response.data) : response.data as T;
      return ApiResponse.success(parsed, statusCode: response.statusCode);
    } catch (e) {
      final err = ApiErrorHandler.handle(e);
      throw err;
    }
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      final parsed = fromJson != null ? fromJson(response.data) : response.data as T;
      return ApiResponse.success(parsed, statusCode: response.statusCode);
    } catch (e) {
      final err = ApiErrorHandler.handle(e);
      throw err;
    }
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      final parsed = fromJson != null ? fromJson(response.data) : response.data as T;
      return ApiResponse.success(parsed, statusCode: response.statusCode);
    } catch (e) {
      final err = ApiErrorHandler.handle(e);
      throw err;
    }
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      final parsed = fromJson != null ? fromJson(response.data) : response.data as T;
      return ApiResponse.success(parsed, statusCode: response.statusCode);
    } catch (e) {
      final err = ApiErrorHandler.handle(e);
      throw err;
    }
  }
}
