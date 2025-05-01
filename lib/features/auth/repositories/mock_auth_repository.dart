import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class MockAuthRepository {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Mock token for authentication
  final String _mockToken = 'mock_token_12345';
  
  // Login user
  Future<UserModel> login(String email, String password) async {
    // Add a 2-second delay to simulate network latency
    await Future.delayed(const Duration(seconds: 2));
    
    // Get user data from storage or create a new default user if none exists
    final userJson = await _secureStorage.read(key: 'user_data');
    
    // If user exists in storage, use that data
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      // Store tokens
      await _secureStorage.write(key: 'access_token', value: _mockToken);
      
      // Return existing user data
      return UserModel.fromJson(userData);
    } else {
      // Create a default profile if none exists
      final profile = ProfileModel(name: 'Користувач', surname: 'Тестовий');
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch,
        email: email.isNotEmpty ? email : 'test@example.com', 
        profile: profile,
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
      );
      
      // Store user data
      await _secureStorage.write(key: 'user_data', value: jsonEncode(user.toJson()));
      
      // Store token
      await _secureStorage.write(key: 'access_token', value: _mockToken);
      
      return user;
    }
  }
  
  // Register new user
  Future<UserModel> register(String email, String password, String name, String surname) async {
    // Add a 2-second delay to simulate network latency
    await Future.delayed(const Duration(seconds: 2));
    
    // Create profile and user models
    final profile = ProfileModel(name: name, surname: surname);
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch,
      email: email,
      profile: profile,
      isActive: true,
      createdAt: DateTime.now().toIso8601String(),
    );
    
    // Store user data
    await _secureStorage.write(key: 'user_data', value: jsonEncode(user.toJson()));
    
    // Store token
    await _secureStorage.write(key: 'access_token', value: _mockToken);
    
    return user;
  }
  
  // Logout user
  Future<void> logout() async {
    // Add a small delay for logout as well
    await Future.delayed(const Duration(milliseconds: 500));
    await _secureStorage.delete(key: 'access_token');
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null;
  }
  
  // Get authenticated user data
  Future<UserModel?> getCurrentUser() async {
    final userJson = await _secureStorage.read(key: 'user_data');
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }
  
  // Get token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
}
