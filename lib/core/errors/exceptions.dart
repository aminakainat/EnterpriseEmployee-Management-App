import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({required this.message, this.statusCode, this.details});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  factory ApiException.fromDioError(DioException error) {
    String message = 'An unexpected network error occurred.';
    int? statusCode = error.response?.statusCode;
    dynamic details = error.response?.data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timed out. Please try again.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request send timed out. Please check your internet.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Response receipt timed out. Server might be slow.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Secure certificate validation failed.';
        break;
      case DioExceptionType.badResponse:
        if (error.response?.data != null && error.response?.data is Map) {
          final data = error.response!.data as Map;
          message = data['message'] ?? data['error'] ?? 'Server error: $statusCode';
        } else {
          message = 'Received invalid response from server ($statusCode).';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.unknown:
        message = error.message ?? 'An unknown error occurred.';
        break;
      default:
        message = 'A network error occurred. Please try again.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      details: details,
    );
  }
}
