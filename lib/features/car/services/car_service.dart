import '../models/car_model.dart';
import '../repositories/advertisement_repository.dart';
import '../repositories/i_car_repository.dart';
import '../repositories/mock_car_repository.dart';
import '../../../core/services/api_config_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CarService {
  // Singleton pattern
  static final CarService _instance = CarService._internal();
  factory CarService() => _instance;
  CarService._internal() {
    _initializeRepository();
  }
  
  // ID користувача, оголошення якого переглядає адміністратор
  int? _selectedUserId;

  // Track booked cars locally
  final List<String> _bookedCarIds = [];
  
  // Сервіс конфігурації API
  final ApiConfigService _apiConfigService = ApiConfigService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
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
      print('CarService: Using AdvertisementRepository with API');
      
      // Перевіряємо, чи є користувач адміном
      final isAdmin = await _isUserAdmin();
      
      // Отримуємо ID автопарку з ApiConfigService
      int fleetId;
      
      if (isAdmin) {
        if (_selectedUserId != null) {
          // Якщо адмін вибрав конкретного користувача
          fleetId = _selectedUserId!;
          print('CarService: Admin viewing fleetId for user: $fleetId');
        } else {
          // За замовчуванням для адміна використовуємо ID = 1
          fleetId = 1;
          print('CarService: Admin user detected, using default admin fleetId: $fleetId');
        }
      } else {
        // Для звичайних користувачів використовуємо збережений fleetId
        fleetId = await _apiConfigService.getFleetId();
        print('CarService: Regular user, using fleetId: $fleetId');
      }
      
      // Використовуємо AdvertisementRepository з ID автопарку
      _carRepository = AdvertisementRepository(fleetId: fleetId.toString());
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

  // Перевіряємо, чи є користувач адміністратором
  Future<bool> _isUserAdmin() async {
    final isAdmin = await _secureStorage.read(key: 'is_admin');
    return isAdmin == 'true';
  }
  
  // Встановлює ID користувача для перегляду адміністратором
  Future<void> setSelectedUserId(int userId) async {
    _selectedUserId = userId;
    print('CarService: Admin selected user ID: $userId');
    // Скидаємо кеш та реініціалізуємо репозиторій з новим ID
    _cachedCars = null;
    await _initializeRepository();
  }
  
  // Очищає вибраний ID користувача
  void clearSelectedUserId() {
    _selectedUserId = null;
    print('CarService: Admin cleared selected user ID');
    _cachedCars = null;
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

  // Book a car (стара реалізація)
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
  
  // Book a car with dates - використовує новий ендпоінт /booking
  Future<void> bookCarWithDates(String carId, DateTime dateFrom, DateTime dateTo) async {
    await _ensureCorrectRepository();
    
    if (!_bookedCarIds.contains(carId)) {
      _bookedCarIds.add(carId);
      try {
        // Якщо це AdvertisementRepository, використовуємо новий метод з датами
        if (_carRepository is AdvertisementRepository) {
          final adRepository = _carRepository as AdvertisementRepository;
          await adRepository.bookCarWithDates(carId, dateFrom, dateTo);
        } else {
          // Для інших репозиторіїв використовуємо стандартний метод
          await _carRepository.bookCar(carId);
        }
        
        // Invalidate cache after booking
        _cachedCars = null;
      } catch (e) {
        print('Error booking car with dates: $e');
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
  
  // Reject a booking by its ID
  Future<void> rejectBooking(String bookingId) async {
    await _ensureCorrectRepository();
    
    try {
      print('DEBUG: CarService - Rejecting booking with ID: $bookingId');
      
      // Use the new rejectBooking method from the repository
      await _carRepository.rejectBooking(bookingId);
      
      // Invalidate cache after rejecting the booking
      _cachedCars = null;
      
      print('DEBUG: CarService - Booking successfully rejected');
    } catch (e) {
      print('ERROR: Failed to reject booking in service: $e');
      rethrow;
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
  
  // Очищення всіх даних користувача при виході з системи
  void clearUserData() {
    print('DEBUG: CarService - clearing all user data');
    // Очищення списку заброньованих автомобілів
    _bookedCarIds.clear();
    
    // Скидання ID вибраного користувача (для адміністраторів)
    _selectedUserId = null;
    
    // Очищення кешу автомобілів
    _cachedCars = null;
    
    // Також можна скинути інші налаштування або стани, якщо потрібно
    print('DEBUG: CarService - all user data cleared');
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
