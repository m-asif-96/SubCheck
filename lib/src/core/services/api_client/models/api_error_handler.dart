import 'package:dio/dio.dart';
import 'api_exception.dart';

class ApiErrorHandler {
  static ApiException handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const ApiException(
            message: 'Connection timed out. Please check your internet connection.',
            statusCode: 408,
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final dynamic data = error.response?.data;
          String message = 'Unexpected error occurred';
          if (data is Map && data.containsKey('message')) {
            message = data['message'].toString();
          } else if (statusCode == 404) {
            message = 'Resource not found';
          } else if (statusCode == 401) {
            message = 'Unauthorized. Please login again.';
          } else if (statusCode == 500) {
            message = 'Internal server error. Please try again later.';
          }
          return ApiException(
            message: message,
            statusCode: statusCode,
            details: data,
          );
        case DioExceptionType.cancel:
          return const ApiException(message: 'Request was cancelled');
        case DioExceptionType.connectionError:
          return const ApiException(
            message: 'Unable to connect to server. Please check your network.',
            statusCode: 503,
          );
        default:
          return ApiException(
            message: error.message ?? 'An unexpected network error occurred',
          );
      }
    }
    return ApiException(message: error?.toString() ?? 'Unknown error occurred');
  }
}
