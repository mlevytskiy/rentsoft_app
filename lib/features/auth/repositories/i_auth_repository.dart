import '../models/user_model.dart';

/// Інтерфейс для авторизаційних репозиторіїв
abstract class IAuthRepository {
  /// Авторизація користувача
  Future<UserModel> login(String email, String password);

  /// Реєстрація нового користувача
  Future<UserModel> register(String email, String password, String name, String surname);

  /// Вихід користувача
  Future<void> logout();

  /// Перевірка, чи користувач авторизований
  Future<bool> isLoggedIn();

  /// Отримання токену доступу
  Future<String?> getToken();
  
  /// Отримання поточного користувача
  Future<UserModel?> getCurrentUser();
}
