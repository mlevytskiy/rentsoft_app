import 'dart:convert';

class AuthErrorModel {
  final Map<String, List<String>> fieldErrors;
  final int? statusCode;
  final String? rawResponse;

  AuthErrorModel({
    required this.fieldErrors,
    this.statusCode,
    this.rawResponse,
  });

  factory AuthErrorModel.fromResponse(dynamic responseData, {int? statusCode}) {
    final Map<String, List<String>> fieldErrors = {};
    
    if (responseData is Map<String, dynamic>) {
      responseData.forEach((key, value) {
        if (key != '_query_stats') {
          if (value is List) {
            fieldErrors[key] = List<String>.from(value);
          } else if (value is String) {
            fieldErrors[key] = [value];
          }
        }
      });
    }

    return AuthErrorModel(
      fieldErrors: fieldErrors,
      statusCode: statusCode,
      rawResponse: responseData is String ? responseData : jsonEncode(responseData),
    );
  }

  String getFirstError() {
    if (fieldErrors.isEmpty) return 'Unknown error occurred';
    
    final firstField = fieldErrors.keys.first;
    final firstError = fieldErrors[firstField]?.first ?? 'Error';
    
    return '$firstField: $firstError';
  }

  String getAllErrors() {
    if (fieldErrors.isEmpty) return 'Unknown error occurred';
    
    return fieldErrors.entries
        .map((e) => '${e.key}: ${e.value.join(', ')}')
        .join('\n');
  }
}
