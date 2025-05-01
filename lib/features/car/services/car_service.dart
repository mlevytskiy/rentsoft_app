import '../models/car_model.dart';
import '../repositories/car_repository.dart';
import '../repositories/i_car_repository.dart';
import '../repositories/mock_car_repository.dart';
import '../../../core/services/api_config_service.dart';

class CarService {
  // Singleton pattern
  static final CarService _instance = CarService._internal();
  factory CarService() => _instance;
  CarService._internal() {
    _initializeRepository();
  }

  // Track booked cars locally
  final List<String> _bookedCarIds = [];
  
  // Сервіс конфігурації API
  final ApiConfigService _apiConfigService = ApiConfigService();
  
  // Repository for car data
  late ICarRepository _carRepository;
  bool _isOfflineMode = false;
  
  // Cache for cars to avoid excessive API calls
  List<Car>? _cachedCars;

  // Ініціалізуємо правильний репозиторій залежно від режиму роботи
  Future<void> _initializeRepository() async {
    _isOfflineMode = await _apiConfigService.isOfflineMode();
    
    if (_isOfflineMode) {
      print('CarService: Using MockCarRepository for offline mode');
      _carRepository = MockCarRepository();
      // Синхронізуємо заброньовані автомобілі з моковим репозиторієм
      _syncBookedCarsWithMockRepository();
    } else {
      print('CarService: Using real CarRepository with API');
      _carRepository = CarRepository();
    }
  }

  // Синхронізуємо дані між сервісом та моковим репозиторієм
  void _syncBookedCarsWithMockRepository() {
    if (_carRepository is MockCarRepository) {
      final mockRepo = _carRepository as MockCarRepository;
      // Додаємо ID з мокового репозиторія до сервісу
      for (var id in mockRepo.bookedCarIds) {
        if (!_bookedCarIds.contains(id)) {
          _bookedCarIds.add(id);
        }
      }
    }
  }

  // Перевіряємо і оновлюємо репозиторій перед кожною дією
  Future<void> _ensureCorrectRepository() async {
    final isCurrentlyOffline = await _apiConfigService.isOfflineMode();
    
    // Якщо режим змінився, оновлюємо репозиторій
    if (isCurrentlyOffline != _isOfflineMode) {
      await _initializeRepository();
      // Скидаємо кеш при зміні режиму
      _cachedCars = null;
    }
  }

  // Book a car
  Future<void> bookCar(String carId) async {
    await _ensureCorrectRepository();
    
    if (!_bookedCarIds.contains(carId)) {
      _bookedCarIds.add(carId);
      try {
        await _carRepository.bookCar(carId);
        // Invalidate cache after booking
        _cachedCars = null;
      } catch (e) {
        print('Error booking car in service: $e');
        // If API call fails, remove from local bookings
        _bookedCarIds.remove(carId);
        rethrow;
      }
    }
  }

  // Unbook a car
  Future<void> unbookCar(String carId) async {
    await _ensureCorrectRepository();
    
    if (_bookedCarIds.contains(carId)) {
      try {
        await _carRepository.unbookCar(carId);
        _bookedCarIds.remove(carId);
        // Invalidate cache after unbooking
        _cachedCars = null;
      } catch (e) {
        print('Error unbooking car in service: $e');
        rethrow;
      }
    }
  }

  // Check if a car is booked
  bool isCarBooked(String carId) {
    return _bookedCarIds.contains(carId);
  }

  // Get booked cars
  Future<List<Car>> getBookedCars() async {
    await _ensureCorrectRepository();
    
    final allCars = await getAllCars();
    return allCars.where((car) => _bookedCarIds.contains(car.id)).toList();
  }

  // Get available cars
  Future<List<Car>> getAvailableCars() async {
    await _ensureCorrectRepository();
    
    final allCars = await getAllCars();
    return allCars.where((car) => !_bookedCarIds.contains(car.id)).toList();
  }

  // Get all cars from repository with caching
  Future<List<Car>> getAllCars() async {
    await _ensureCorrectRepository();
    
    if (_cachedCars != null) {
      return _cachedCars!;
    }
    
    try {
      _cachedCars = await _carRepository.getCars();
      return _cachedCars!;
    } catch (e) {
      print('Error getting cars: $e');
      // Return empty list on error
      return [];
    }
  }

  // Get car by ID
  Future<Car?> getCarById(String id) async {
    await _ensureCorrectRepository();
    
    try {
      return await _carRepository.getCarById(id);
    } catch (e) {
      print('Error getting car by ID: $e');
      return null;
    }
  }

  // Manually clear cache to force refresh
  void clearCache() {
    _cachedCars = null;
  }

  // Filter cars by search query
  Future<List<Car>> filterCarsByQuery(String query) async {
    await _ensureCorrectRepository();
    
    if (query.isEmpty) {
      return await getAllCars();
    }

    final cars = await getAllCars();
    final lowercaseQuery = query.toLowerCase();
    return cars.where((car) {
      final fullName = car.fullName.toLowerCase();
      return fullName.contains(lowercaseQuery);
    }).toList();
  }

  // Filter cars by various parameters
  Future<List<Car>> filterCars({
    String? query,
    int? minPrice,
    int? maxPrice,
    String? brand,
    int? seats,
    String? fuelType,
    String? carPark,
  }) async {
    await _ensureCorrectRepository();
    
    var cars = query != null && query.isNotEmpty
        ? await filterCarsByQuery(query)
        : await getAllCars();

    if (minPrice != null) {
      cars = cars.where((car) => car.pricePerWeek >= minPrice).toList();
    }

    if (maxPrice != null) {
      cars = cars.where((car) => car.pricePerWeek <= maxPrice).toList();
    }

    if (brand != null && brand.isNotEmpty) {
      cars = cars.where((car) => car.brand == brand).toList();
    }

    if (seats != null) {
      cars = cars.where((car) => car.seats >= seats).toList();
    }

    if (fuelType != null && fuelType.isNotEmpty) {
      cars = cars.where((car) => car.fuelType == fuelType).toList();
    }

    if (carPark != null && carPark.isNotEmpty) {
      cars = cars.where((car) => car.carPark == carPark).toList();
    }

    return cars;
  }
}
