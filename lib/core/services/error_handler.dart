import 'package:dio/dio.dart';
import '../../features/auth/models/auth_error_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final AuthErrorModel? authError;

  ApiException({required this.message, this.statusCode, this.authError});

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
                // Create a structured error model for API errors
                final authError = AuthErrorModel.fromResponse(data, statusCode: statusCode);
                
                if (authError.fieldErrors.isNotEmpty) {
                  // Set first error as message for backward compatibility
                  message = authError.getFirstError();
                  return ApiException(
                    message: message, 
                    statusCode: statusCode,
                    authError: authError
                  );
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
