import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/api/api_client.dart';
import '../../../core/services/error_handler.dart';
import '../models/car_model.dart';
import 'i_car_repository.dart';

/// Репозиторій для отримання оголошень автомобілів від конкретного автопарку
class AdvertisementRepository implements ICarRepository {
  final ApiClient _apiClient;
  final String fleetId; // ID автопарку, який використовуватиметься в запитах
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AdvertisementRepository({required this.fleetId}) : _apiClient = ApiClient();

  @override
  Future<List<Car>> getCars() async {
    try {
      // Перевіряємо чи є активний токен авторизації
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        print(
            'DEBUG: AdvertisementRepository - токен відсутній, повертаємо порожній масив');
        return []; // Повертаємо порожній масив, якщо користувач не авторизований
      }

      print(
          'DEBUG: AdvertisementRepository - запит з fleetId=$fleetId та токеном');
      // Використовуємо ендпоінт /users/{id}/advertisements для отримання оголошень конкретного автопарку
      final response = await _apiClient.get('/users/$fleetId/advertisements');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Сервер повертає дані у структурі з ключем "data"
        final List<dynamic> carsData = response.data is List
            ? response.data
            : (response.data['data'] is List
                ? response.data['data']
                : (response.data['results'] is List
                    ? response.data['results']
                    : []));

        print(
            'DEBUG: Відповідь API: ${response.data.toString().substring(0, min(100, response.data.toString().length))}...');

        print(
            'DEBUG: AdvertisementRepository - отримано ${carsData.length} оголошень');
        return carsData.map((car) => _mapToCar(car)).toList();
      } else {
        throw ApiException(
            message: 'Failed to load advertisements: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DEBUG: DioException при отриманні оголошень: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      print('DEBUG: Помилка при отриманні оголошень: $e');
      throw ApiException(
          message: 'Помилка при отриманні списку автомобілів: $e');
    }
  }

  @override
  Future<Car?> getCarById(String id) async {
    try {
      // Спочатку отримуємо всі автомобілі
      final cars = await getCars();

      // Шукаємо потрібний по ID
      return cars.firstWhere((car) => car.id == id,
          orElse: () => throw ApiException(message: 'Автомобіль не знайдено'));
    } catch (e) {
      print('DEBUG: Помилка при отриманні деталей автомобіля: $e');
      rethrow;
    }
  }

  @override
  Future<void> bookCar(String carId) async {
    try {
      // Використовуємо стару версію API для сумісності
      await _apiClient.post('/advertisements/$carId/book');
    } catch (e) {
      print('DEBUG: Помилка бронювання автомобіля: $e');
      throw ApiException(message: 'Не вдалося забронювати автомобіль');
    }
  }

  /// Бронювання автомобіля з використанням нового API ендпоінту `/booking`
  /// з передачею дат початку та закінчення оренди
  Future<void> bookCarWithDates(
      String advertId, DateTime dateFrom, DateTime dateTo) async {
    try {
      // Форматуємо дати у ISO 8601 формат
      final dateFromStr = dateFrom.toIso8601String();
      final dateToStr = dateTo.toIso8601String();

      print('DEBUG: Бронювання автомобіля з датами: $dateFromStr - $dateToStr');

      // Відправляємо POST запит на ендпоінт /bookings з параметрами
      await _apiClient.post('/bookings', data: {
        'date_from': dateFromStr,
        'date_to': dateToStr,
        'advert': advertId,
      });
    } catch (e) {
      print('DEBUG: Помилка бронювання автомобіля з датами: $e');
      throw ApiException(
          message: 'Не вдалося забронювати автомобіль з вказаними датами');
    }
  }

  @override
  Future<void> unbookCar(String carId) async {
    try {
      await _apiClient.post('/advertisements/$carId/unbook');
    } catch (e) {
      print('DEBUG: Помилка при скасуванні бронювання: $e');
      throw ApiException(message: 'Не вдалося скасувати бронювання');
    }
  }
  
  @override
  Future<void> rejectBooking(String bookingId) async {
    try {
      print('DEBUG: Відхилення бронювання з ID: $bookingId');
      
      // Використовуємо новий ендпоінт DELETE /booking/{id} для відхилення бронювання
      await _apiClient.delete('/bookings/$bookingId');
      print('DEBUG: Бронювання успішно відхилено');
    } catch (e) {
      print('DEBUG: Помилка при відхиленні бронювання: $e');
      throw ApiException(message: 'Не вдалося відхилити бронювання');
    }
  }

  // Map JSON response to Car model
  Car _mapToCar(Map<String, dynamic> data) {
    print('DEBUG: Маппінг авто: ${data.keys.join(', ')}');

    // Визначаємо ціну на основі доступних полів
    int price = 2000;
    if (data['price'] != null && data['price'] is num) {
      price = (data['price'] as num).toInt();
    } else if (data['price_per_week'] != null &&
        data['price_per_week'] is num) {
      price = (data['price_per_week'] as num).toInt();
    } else if (data['pricePerWeek'] != null && data['pricePerWeek'] is num) {
      price = (data['pricePerWeek'] as num).toInt();
    }

    // Визначаємо тип пального
    String fuelTypeStr = 'Бензин';
    if (data['fuel_type'] is String) {
      fuelTypeStr = data['fuel_type'];
    } else if (data['fuelType'] is String) {
      fuelTypeStr = data['fuelType'];
    } else if (data['fuel_type'] is List &&
        (data['fuel_type'] as List).isNotEmpty) {
      // Якщо поле fuel_type - це список ID, використовуємо мапінг ID -> Назва
      final fuelTypeId = (data['fuel_type'] as List).first;
      final fuelTypeMap = {
        1: 'Бензин',
        2: 'Дизель',
        3: 'Газ',
        4: 'Електро',
        5: 'Гібрид',
      };
      fuelTypeStr = fuelTypeMap[fuelTypeId] ?? 'Бензин';
    }

    return Car(
      id: data['id']?.toString() ?? '',
      brand: data['car_brand'] ?? data['brand'] ?? data['make'] ?? '',
      model: data['car_model'] ?? data['model'] ?? '',
      year: data['year'] ?? 2023,
      imageUrl: data['image_url'] ??
          data['imageUrl'] ??
          'https://cdn3.riastatic.com/photosnew/auto/photo/default_photo__476620743f.jpg',
      pricePerWeek: price,
      fuelType: fuelTypeStr,
      seats: data['seats'] ?? 5,
      carPark:
          data['location'] ?? data['car_park'] ?? data['carPark'] ?? 'Автопарк',
    );
  }
}
