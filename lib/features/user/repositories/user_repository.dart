import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rentsoft_app/core/services/api_config_service.dart';
import 'package:rentsoft_app/features/user/models/car_model.dart';
import 'package:rentsoft_app/features/user/models/user_with_ads_count.dart';

class UserRepository {
  final Dio _dio = Dio();
  final ApiConfigService _apiConfigService = ApiConfigService();

  // Логування API-запитів
  void _logApiCall(String method, String url, {dynamic data, dynamic headers, dynamic response, dynamic error}) {
    debugPrint('\n==== API CALL: $method $url ====');

    if (headers != null) {
      debugPrint('HEADERS: ${jsonEncode(headers)}');
    }

    if (data != null) {
      debugPrint('REQUEST DATA: ${jsonEncode(data)}');
    }

    if (response != null) {
      debugPrint('RESPONSE STATUS: ${response['status_code']}');
      debugPrint('RESPONSE DATA: ${jsonEncode(response['data'])}');
    }

    if (error != null) {
      debugPrint('ERROR: $error');
    }

    debugPrint('==== END API CALL ====\n');
  }

  // Базові типи для автомобільних оголошень
  final List<String> _defaultFuelTypes = [
    'Бензин',
    'Дизель',
    'Електро',
    'Гібрид',
    'Газ/Бензин',
  ];

  final List<String> _defaultTransmissions = [
    'Механічна',
    'Автоматична',
    'Варіатор',
    'Роботизована',
  ];

  final List<String> _defaultCategories = [
    'Седан',
    'Хетчбек',
    'Універсал',
    'Кросовер',
    'Позашляховик',
    'Мінівен',
  ];

  final List<String> _defaultStatuses = [
    'Доступно',
    'Орендовано',
    'На обслуговуванні',
    'Недоступно',
  ];

  // Отримати список всіх користувачів
  Future<Map<String, dynamic>> getAllUsers() async {
    final url = '${await _apiConfigService.getBaseUrl()}users';
    _logApiCall('GET', url, data: null);

    try {
      final token = await _apiConfigService.getToken();

      // Prepare headers with authentication token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      _logApiCall('GET', url, headers: headers);

      // Make the API request
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      // Prepare response for display
      final result = {
        'status_code': response.statusCode,
        'data': response.data,
        'headers': response.headers.map,
        'request_url': url,
      };

      _logApiCall('GET', url, response: result);

      // Return the raw response for display
      return result;
    } catch (e) {
      dynamic result;

      if (e is DioException && e.response != null) {
        // If there's a response from the server, but it's an error
        result = {
          'status_code': e.response?.statusCode,
          'data': e.response?.data,
          'error_message': e.message,
          'headers': e.response?.headers.map,
        };
      } else {
        // For other errors
        result = {
          'status_code': 500,
          'error_message': e.toString(),
        };
      }

      _logApiCall('GET', url, error: e.toString());
      return result;
    }
  }

  // Отримати оголошення користувача за ID
  Future<Map<String, dynamic>> getUserAdvertisements(int userId) async {
    final url = '${await _apiConfigService.getBaseUrl()}users/$userId/advertisements';
    _logApiCall('GET', url, data: {'userId': userId});

    try {
      final token = await _apiConfigService.getToken();

      // Prepare headers with authentication token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      _logApiCall('GET', url, headers: headers);

      // Make the API request
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      // Prepare response for display
      final result = {
        'status_code': response.statusCode,
        'data': response.data,
        'headers': response.headers.map,
        'request_url': url,
        'userId': userId, // Додаємо ID користувача для зручності
      };

      _logApiCall('GET', url, response: result);

      // Return the raw response for display
      return result;
    } catch (e) {
      dynamic result;

      if (e is DioException && e.response != null) {
        // If there's a response from the server, but it's an error
        result = {
          'status_code': e.response?.statusCode,
          'data': e.response?.data,
          'error_message': e.message,
          'headers': e.response?.headers.map,
          'userId': userId, // Додаємо ID користувача для зручності
        };
      } else {
        // For other errors
        result = {
          'status_code': 500,
          'error_message': e.toString(),
          'userId': userId, // Додаємо ID користувача для зручності
        };
      }

      _logApiCall('GET', url, error: e.toString());
      return result;
    }
  }

  // Отримати список користувачів з кількістю оголошень для кожного
  Future<List<UserWithAdsCount>> getUsersWithAdsCount() async {
    try {
      // Отримуємо список користувачів
      final usersResponse = await getAllUsers();

      if (usersResponse['status_code'] != 200) {
        throw Exception('Failed to load users: ${usersResponse['error_message'] ?? "Unknown error"}');
      }

      final List<dynamic> users = usersResponse['data']['data'];
      final List<UserWithAdsCount> usersWithAds = [];

      // Для кожного користувача отримуємо кількість оголошень
      for (var user in users) {
        try {
          final userId = user['id'] as int;
          final name = user['profile']?['name'] as String? ?? 'Unknown';
          final surname = user['profile']?['surname'] as String? ?? 'User';

          // Отримуємо оголошення для користувача
          final adsResponse = await getUserAdvertisements(userId);
          int adsCount = 0;

          if (adsResponse['status_code'] == 200) {
            // Якщо успішна відповідь, рахуємо кількість оголошень
            if (adsResponse['data'] is List) {
              adsCount = (adsResponse['data'] as List).length;
            } else if (adsResponse['data'] is Map && adsResponse['data'].containsKey('results')) {
              adsCount = (adsResponse['data']['results'] as List).length;
            }
          }

          // Додаємо користувача з кількістю оголошень до списку
          usersWithAds.add(UserWithAdsCount(
            id: userId,
            name: name,
            surname: surname,
            adsCount: adsCount,
          ));
        } catch (e) {
          // Пропускаємо користувача при помилці
          continue;
        }
      }

      return usersWithAds;
    } catch (e) {
      throw Exception('Error loading users with ads count: $e');
    }
  }

  // Створити нове оголошення автомобіля для користувача
  Future<Map<String, dynamic>> createCarAdvertisement(int userId, CarModel car) async {
    //@TODO: need replace to advertisement for specific user base on userId
    final url = '${await _apiConfigService.getBaseUrl()}advertisements';

    try {
      final token = await _apiConfigService.getToken();

      // Prepare headers with authentication token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Конвертуємо дані авто в JSON
      final carData = car.toJson();

      // Логуємо запит
      debugPrint('\n==== CREATING ADVERTISEMENT FOR USER $userId ====');
      _logApiCall('POST', url, data: carData, headers: headers);

      // Make the API request to create advertisement
      final response = await _dio.post(
        url,
        options: Options(headers: headers),
        data: carData,
      );

      // Prepare response for display
      final result = {
        'status_code': response.statusCode,
        'data': response.data,
        'headers': response.headers.map,
        'request_url': url,
        'user_id': userId, // Додаємо ID користувача для перевірки
        'car_data': car.toJson(), // Додаємо дані автомобіля в результат
      };

      _logApiCall('POST', url, response: result);
      debugPrint('==== ADVERTISEMENT CREATED SUCCESSFULLY ====\n');

      // Return the raw response for display
      return result;
    } catch (e) {
      dynamic result;

      if (e is DioException && e.response != null) {
        // If there's a response from the server, but it's an error
        result = {
          'status_code': e.response?.statusCode,
          'data': e.response?.data,
          'error_message': e.message,
          'headers': e.response?.headers.map,
          'user_id': userId,
        };

        debugPrint('\n==== ERROR CREATING ADVERTISEMENT ====');
        debugPrint('Error status: ${e.response?.statusCode}');
        debugPrint('Error data: ${e.response?.data}');
        debugPrint('Error message: ${e.message}');
      } else {
        // For other errors
        result = {
          'status_code': 500,
          'error_message': e.toString(),
          'user_id': userId,
        };

        debugPrint('\n==== ERROR CREATING ADVERTISEMENT ====');
        debugPrint('Error: ${e.toString()}');
      }

      _logApiCall('POST', url, error: e.toString());
      debugPrint('==== END ERROR CREATING ADVERTISEMENT ====\n');
      return result;
    }
  }

  // Створити тип палива
  Future<Map<String, dynamic>> createFuelType(String name) async {
    try {
      final baseUrl = await _apiConfigService.getBaseUrl();
      final token = await _apiConfigService.getToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _dio.post(
        '${baseUrl}advertisements/fuel_types',
        options: Options(headers: headers),
        data: {'name': name},
      );

      return {
        'status_code': response.statusCode,
        'data': response.data,
        'headers': response.headers.map,
      };
    } catch (e) {
      if (e is DioException && e.response != null) {
        return {
          'status_code': e.response?.statusCode,
          'data': e.response?.data,
          'error_message': e.message,
          'headers': e.response?.headers.map,
        };
      } else {
        return {
          'status_code': 500,
          'error_message': e.toString(),
        };
      }
    }
  }

  // Створити тип трансмісії
  Future<Map<String, dynamic>> createTransmission(String name) async {
    try {
      final baseUrl = await _apiConfigService.getBaseUrl();
      final token = await _apiConfigService.getToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _dio.post(
        '${baseUrl}advertisements/transmissions',
        options: Options(headers: headers),
        data: {'name': name},
      );

      return {
        'status_code': response.statusCode,
        'data': response.data,
        'headers': response.headers.map,
      };
    } catch (e) {
      if (e is DioException && e.response != null) {
        return {
          'status_code': e.response?.statusCode,
          'data': e.response?.data,
          'error_message': e.message,
          'headers': e.response?.headers.map,
        };
      } else {
        return {
          'status_code': 500,
          'error_message': e.toString(),
        };
      }
    }
  }

  // Створити категорію
  Future<Map<String, dynamic>> createCategory(String name) async {
    try {
      final baseUrl = await _apiConfigService.getBaseUrl();
      final token = await _apiConfigService.getToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _dio.post(
        '${baseUrl}advertisements/categories',
        options: Options(headers: headers),
        data: {'name': name},
      );

      return {
        'status_code': response.statusCode,
        'data': response.data,
        'headers': response.headers.map,
      };
    } catch (e) {
      if (e is DioException && e.response != null) {
        return {
          'status_code': e.response?.statusCode,
          'data': e.response?.data,
          'error_message': e.message,
          'headers': e.response?.headers.map,
        };
      } else {
        return {
          'status_code': 500,
          'error_message': e.toString(),
        };
      }
    }
  }

  // Створити статус
  Future<Map<String, dynamic>> createStatus(String name) async {
    try {
      final baseUrl = await _apiConfigService.getBaseUrl();
      final token = await _apiConfigService.getToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _dio.post(
        '${baseUrl}advertisements/statuses',
        options: Options(headers: headers),
        data: {'name': name},
      );

      return {
        'status_code': response.statusCode,
        'data': response.data,
        'headers': response.headers.map,
      };
    } catch (e) {
      if (e is DioException && e.response != null) {
        return {
          'status_code': e.response?.statusCode,
          'data': e.response?.data,
          'error_message': e.message,
          'headers': e.response?.headers.map,
        };
      } else {
        return {
          'status_code': 500,
          'error_message': e.toString(),
        };
      }
    }
  }

  // Створити базові значення для оголошень
  Future<Map<String, dynamic>> createBaseValues() async {
    debugPrint('\n==== STARTING CREATION OF BASE VALUES ====');

    Map<String, dynamic> results = {
      'fuel_types': [],
      'transmissions': [],
      'categories': [],
      'statuses': [],
      'errors': [],
    };

    // Створюємо типи палива
    debugPrint('Creating fuel types...');
    for (var fuelType in _defaultFuelTypes) {
      try {
        debugPrint('  Creating fuel type: $fuelType');
        final response = await createFuelType(fuelType);
        if (response['status_code'] == 201) {
          results['fuel_types'].add(response['data']);
          debugPrint('  ✓ Fuel type "$fuelType" created successfully with ID: ${response['data']['id']}');
        } else {
          final errorMsg =
              'Не вдалось створити тип палива "$fuelType": ${response['error_message'] ?? ""} (${response['status_code']})';
          results['errors'].add(errorMsg);
          debugPrint('  ✗ $errorMsg');
        }
      } catch (e) {
        final errorMsg = 'Помилка при створенні типу палива "$fuelType": $e';
        results['errors'].add(errorMsg);
        debugPrint('  ✗ $errorMsg');
      }
    }

    // Створюємо типи трансмісій
    debugPrint('Creating transmissions...');
    for (var transmission in _defaultTransmissions) {
      try {
        debugPrint('  Creating transmission: $transmission');
        final response = await createTransmission(transmission);
        if (response['status_code'] == 201) {
          results['transmissions'].add(response['data']);
          debugPrint('  ✓ Transmission "$transmission" created successfully with ID: ${response['data']['id']}');
        } else {
          final errorMsg =
              'Не вдалось створити тип трансмісії "$transmission": ${response['error_message'] ?? ""} (${response['status_code']})';
          results['errors'].add(errorMsg);
          debugPrint('  ✗ $errorMsg');
        }
      } catch (e) {
        final errorMsg = 'Помилка при створенні типу трансмісії "$transmission": $e';
        results['errors'].add(errorMsg);
        debugPrint('  ✗ $errorMsg');
      }
    }

    // Створюємо категорії
    debugPrint('Creating categories...');
    for (var category in _defaultCategories) {
      try {
        debugPrint('  Creating category: $category');
        final response = await createCategory(category);
        if (response['status_code'] == 201) {
          results['categories'].add(response['data']);
          debugPrint('  ✓ Category "$category" created successfully with ID: ${response['data']['id']}');
        } else {
          final errorMsg =
              'Не вдалось створити категорію "$category": ${response['error_message'] ?? ""} (${response['status_code']})';
          results['errors'].add(errorMsg);
          debugPrint('  ✗ $errorMsg');
        }
      } catch (e) {
        final errorMsg = 'Помилка при створенні категорії "$category": $e';
        results['errors'].add(errorMsg);
        debugPrint('  ✗ $errorMsg');
      }
    }

    // Створюємо статуси
    debugPrint('Creating statuses...');
    for (var status in _defaultStatuses) {
      try {
        debugPrint('  Creating status: $status');
        final response = await createStatus(status);
        if (response['status_code'] == 201) {
          results['statuses'].add(response['data']);
          debugPrint('  ✓ Status "$status" created successfully with ID: ${response['data']['id']}');
        } else {
          final errorMsg =
              'Не вдалось створити статус "$status": ${response['error_message'] ?? ""} (${response['status_code']})';
          results['errors'].add(errorMsg);
          debugPrint('  ✗ $errorMsg');
        }
      } catch (e) {
        final errorMsg = 'Помилка при створенні статусу "$status": $e';
        results['errors'].add(errorMsg);
        debugPrint('  ✗ $errorMsg');
      }
    }

    // Підсумок створення базових значень
    debugPrint('\n==== BASE VALUES CREATION SUMMARY ====');
    debugPrint('Fuel types created: ${results['fuel_types'].length}/${_defaultFuelTypes.length}');
    debugPrint('Transmissions created: ${results['transmissions'].length}/${_defaultTransmissions.length}');
    debugPrint('Categories created: ${results['categories'].length}/${_defaultCategories.length}');
    debugPrint('Statuses created: ${results['statuses'].length}/${_defaultStatuses.length}');
    debugPrint('Errors: ${results['errors'].length}');
    debugPrint('==== END BASE VALUES CREATION ====\n');

    return results;
  }
}
