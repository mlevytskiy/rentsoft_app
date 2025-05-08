import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/error_handler.dart';
import '../models/car_model.dart';
import 'i_car_repository.dart';

/// Репозиторій для отримання оголошень автомобілів від конкретного автопарку
class AdvertisementRepository implements ICarRepository {
  final ApiClient _apiClient;
  final String fleetId; // ID автопарку, який використовуватиметься в запитах
  
  AdvertisementRepository({required this.fleetId}) : _apiClient = ApiClient();
  
  @override
  Future<List<Car>> getCars() async {
    try {
      // Використовуємо ендпоінт /users/{id}/advertisements для отримання оголошень конкретного автопарку
      final response = await _apiClient.get('/users/$fleetId/advertisements');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> carsData = response.data is List 
            ? response.data 
            : (response.data['results'] is List ? response.data['results'] : []);
            
        print('DEBUG: AdvertisementRepository - отримано ${carsData.length} оголошень');
        return carsData.map((car) => _mapToCar(car)).toList();
      } else {
        throw ApiException(message: 'Failed to load advertisements: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DEBUG: DioException при отриманні оголошень: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      print('DEBUG: Помилка при отриманні оголошень: $e');
      throw ApiException(message: 'Помилка при отриманні списку автомобілів: $e');
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
      await _apiClient.post('/advertisements/$carId/book');
    } catch (e) {
      print('DEBUG: Помилка бронювання автомобіля: $e');
      throw ApiException(message: 'Не вдалося забронювати автомобіль');
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
  
  // Map JSON response to Car model
  Car _mapToCar(Map<String, dynamic> data) {
    return Car(
      id: data['id']?.toString() ?? '',
      brand: data['brand'] ?? data['make'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 2023,
      imageUrl: data['image_url'] ?? data['imageUrl'] ?? 'https://cdn3.riastatic.com/photosnew/auto/photo/default_photo__476620743f.jpg',
      pricePerWeek: data['price_per_week'] ?? data['pricePerWeek'] ?? 2000,
      fuelType: data['fuel_type'] ?? data['fuelType'] ?? 'Бензин',
      seats: data['seats'] ?? 5,
      carPark: data['car_park'] ?? data['carPark'] ?? 'Автопарк',
    );
  }
}
