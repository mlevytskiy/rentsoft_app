import '../models/user_model.dart';

/// Інтерфейс для авторизаційних репозиторіїв
abstract class IAuthRepository {
  /// Авторизація користувача
  Future<UserModel> login(String email, String password, {bool isAdmin = false});

  /// Реєстрація нового користувача
  Future<UserModel> register(String email, String password, String name, String surname);

  /// Вихід користувача
  Future<void> logout();

  /// Перевірка, чи користувач авторизований
  Future<bool> isLoggedIn();

  /// Отримання токену доступу
  Future<String?> getToken();
  
  /// Перевірка, чи є валідний токен доступу
  Future<bool> hasValidToken();
  
  /// Отримання поточного користувача
  Future<UserModel?> getCurrentUser();
  
  /// Отримання повних даних користувача у вигляді Map для відображення
  Future<Map<String, dynamic>?> getUserData();
}
