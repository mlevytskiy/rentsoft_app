import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;

  factory ApiException.fromDioError(DioException error) {
    String message = 'Something went wrong';
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              final data = error.response?.data;
              if (data is Map<String, dynamic>) {
                // Try to extract the first field error
                final errorMessages = <String>[];
                data.forEach((key, value) {
                  if (key != '_query_stats' && value is List && value.isNotEmpty) {
                    errorMessages.add('$key: ${value.join(", ")}');
                  }
                });
                if (errorMessages.isNotEmpty) {
                  message = errorMessages.join('\n');
                } else {
                  message = 'Bad request';
                }
              } else {
                message = 'Bad request';
              }
              break;
            case 401:
              message = 'Unauthorized';
              break;
            case 403:
              message = 'Forbidden';
              break;
            case 404:
              message = 'Not found';
              break;
            case 500:
              message = 'Internal server error';
              break;
            default:
              message = 'Server error (${error.response?.statusCode})';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection';
        break;
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          message = 'No internet connection';
        }
        break;
      default:
        message = 'Unexpected error occurred';
    }

    return ApiException(message: message, statusCode: statusCode);
  }
}
