import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/error_handler.dart';
import '../../../core/services/logout_service.dart';
import '../models/user_model.dart';
import 'i_auth_repository.dart';
import 'dart:convert';

class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRepository(this._apiClient);

  @override
  Future<UserModel> login(String email, String password, {bool isAdmin = false}) async {
    try {
      // Використовуємо один ендпоінт '/auth', але додаємо флаг адміна в дані запиту
      final loginData = LoginRequest(
        email: email, 
        password: password,
        isAdmin: isAdmin,  // Додаємо флаг в запит
      ).toJson();
      
      final response = await _apiClient.post(
        '/auth',  // Завжди використовуємо стандартний ендпоінт
        data: loginData,
      );
      
      // Сервер може повертати статус 200 або 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract tokens from headers or response
        final refreshToken = response.data['refresh'];
        final accessToken = response.data['access'];
        
        // Store tokens securely
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        await _secureStorage.write(key: 'access_token', value: accessToken);
        await _secureStorage.write(key: 'is_admin', value: isAdmin.toString());
        
        // Зберігаємо дані користувача для подальшого використання
        final userJson = response.data['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson);
        await _secureStorage.write(key: 'user_data', value: jsonEncode(response.data));
        
        // Return user data
        return user;
      } else {
        throw ApiException(message: 'Failed to login');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name, String surname) async {
    try {
      final profile = ProfileModel(name: name, surname: surname);
      final registerData = RegisterRequest(
        email: email,
        password: password,
        profile: profile,
      );
      
      final response = await _apiClient.post(
        '/auth/register',
        data: registerData.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract tokens from headers or response
        final refreshToken = response.data['refresh'];
        final accessToken = response.data['access'];
        
        // Store tokens securely
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        await _secureStorage.write(key: 'access_token', value: accessToken);
        
        // Зберігаємо дані користувача для подальшого використання
        final userJson = response.data['user'] as Map<String, dynamic>;
        
        // Переконаємося, що профіль містить правильну інформацію
        if (userJson.containsKey('profile') && userJson['profile'] is Map<String, dynamic>) {
          // Переконуємося, що profile.is_verified = false (для нових користувачів)
          if (!userJson['profile'].containsKey('is_verified')) {
            (userJson['profile'] as Map<String, dynamic>)['is_verified'] = false;
          }
        }
        
        print('DEBUG: Register response - user: $userJson');
        final user = UserModel.fromJson(userJson);
        await _secureStorage.write(key: 'user_data', value: jsonEncode(response.data));
        
        // Return user data
        return user;
      } else {
        throw ApiException(message: 'Failed to register');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    // Використовуємо централізований LogoutService замість лише видалення з SecureStorage
    final logoutService = LogoutService();
    await logoutService.clearAllUserData();
    print('DEBUG: AuthRepository - logout completed');
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null;
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
  
  @override
  Future<UserModel?> getCurrentUser() async {
    final userDataString = await _secureStorage.read(key: 'user_data');
    if (userDataString != null) {
      try {
        // Перетворюємо рядок у JSON об'єкт
        final Map<String, dynamic> fullData = Map<String, dynamic>.from(
          json.decode(userDataString)
        );
        
        // Перевіряємо структуру даних - чи є поле 'user' в даних
        if (fullData.containsKey('user')) {
          print('DEBUG: getCurrentUser - знайдено поле user в даних');
          return UserModel.fromJson(fullData['user']);
        } else {
          // Якщо немає окремого поля 'user', спробуємо використати самі дані
          print('DEBUG: getCurrentUser - використовуємо всі дані як об\'єкт користувача');
          return UserModel.fromJson(fullData);
        }
      } catch (e) {
        print('DEBUG: Помилка при парсингу даних користувача: $e');
        return null;
      }
    }
    print('DEBUG: Дані користувача не знайдені в сховищі');
    return null;
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataString = await _secureStorage.read(key: 'user_data');
      if (userDataString != null) {
        return json.decode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// Клас для запиту авторизації
class LoginRequest {
  final String email;
  final String password;
  final bool isAdmin;

  LoginRequest({
    required this.email,
    required this.password,
    this.isAdmin = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'is_admin': isAdmin, // Додаємо поле is_admin для серверної обробки
    };
  }
}

// Клас для запиту реєстрації
class RegisterRequest {
  final String email;
  final String password;
  final ProfileModel profile;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.profile,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'profile': profile.toJson(),
    };
  }
}
