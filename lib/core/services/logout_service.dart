import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/car/services/car_service.dart';

/// A service responsible for clearing all user data when logging out
class LogoutService {
  // Singleton pattern
  static final LogoutService _instance = LogoutService._internal();
  factory LogoutService() => _instance;
  LogoutService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final CarService _carService = CarService();

  /// Clears all user data from both secure storage and memory
  Future<void> clearAllUserData() async {
    print('DEBUG: LogoutService - clearing all user data');
    
    // 1. Clear secure storage (tokens, user data, etc.)
    await _secureStorage.deleteAll();
    
    // 2. Clear in-memory data in CarService
    _carService.clearUserData();
    
    // Add more service clear calls here as needed
    // For example: _userService.clearUserData(), _preferencesService.clearPreferences(), etc.
    
    print('DEBUG: LogoutService - all user data has been cleared');
  }
}
