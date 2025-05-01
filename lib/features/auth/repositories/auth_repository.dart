import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/error_handler.dart';
import '../models/user_model.dart';
import 'i_auth_repository.dart';
import 'dart:convert';

class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRepository(this._apiClient);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth',
        data: LoginRequest(email: email, password: password).toJson(),
      );
      
      if (response.statusCode == 201) {
        // Extract tokens from headers or response
        final refreshToken = response.data['refresh'];
        final accessToken = response.data['access'];
        
        // Store tokens securely
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        await _secureStorage.write(key: 'access_token', value: accessToken);
        
        // Зберігаємо дані користувача для подальшого використання
        final user = UserModel.fromJson(response.data);
        await _secureStorage.write(key: 'user_data', value: response.data.toString());
        
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
      
      if (response.statusCode == 201) {
        // Extract tokens from headers or response
        final refreshToken = response.data['refresh'];
        final accessToken = response.data['access'];
        
        // Store tokens securely
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        await _secureStorage.write(key: 'access_token', value: accessToken);
        
        // Зберігаємо дані користувача для подальшого використання
        final user = UserModel.fromJson(response.data);
        await _secureStorage.write(key: 'user_data', value: response.data.toString());
        
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
    await _secureStorage.deleteAll();
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
        final Map<String, dynamic> userData = Map<String, dynamic>.from(
          json.decode(userDataString)
        );
        return UserModel.fromJson(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
