import 'package:shared_preferences/shared_preferences.dart';

class ApiConfigService {
  static const String _baseUrlKey = 'base_url';
  static const String _urlOptionKey = 'url_option'; // Ключ для опції URL
  static const String _withoutInternetValue = 'no-internet';
  static const String _localhostUrl = 'http://localhost:8888/';
  static const String _publicUrl = 'http://rentsoft-env-1.eba-xkfjndpj.us-east-1.elasticbeanstalk.com/api/';
  static const String _usageScenarioKey = 'usage_scenario'; // Ключ для сценарію використання
  static const String _accessTokenKey = 'access_token'; // Ключ для токена доступу
  static const String _fleetIdKey = 'fleet_id'; // Ключ для ID автопарка

  // Сервіс-сінглтон
  static final ApiConfigService _instance = ApiConfigService._internal();
  factory ApiConfigService() => _instance;
  ApiConfigService._internal();

  // Кешована копія базового URL
  String? _cachedBaseUrl;

  // Отримати поточний базовий URL
  Future<String> getBaseUrl() async {
    if (_cachedBaseUrl != null) {
      return _cachedBaseUrl!;
    }

    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(_baseUrlKey);

    // Якщо URL ще не було збережено, використовувати режим "Without internet" за замовчуванням
    _cachedBaseUrl = baseUrl ?? _publicUrl;
    return _cachedBaseUrl!;
  }

  // Зберегти новий базовий URL
  Future<void> setBaseUrl(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, baseUrl);
    _cachedBaseUrl = baseUrl;
  }

  // Зберегти вибрану опцію URL (для відновлення вибору користувача)
  Future<void> saveUrlOption(String optionName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlOptionKey, optionName);
  }

  // Отримати збережену опцію URL
  Future<String?> getSavedUrlOption() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_urlOptionKey);
  }

  // Перевірити, чи поточний режим - без інтернету (мок дані)
  Future<bool> isOfflineMode() async {
    final baseUrl = await getBaseUrl();
    return baseUrl == _withoutInternetValue;
  }

  // Перевірити, чи використовується публічний URL
  Future<bool> isUsingPublicUrl() async {
    final baseUrl = await getBaseUrl();
    return baseUrl == _publicUrl;
  }

  // Отримати локальний URL
  String getLocalhostUrl() => _localhostUrl;

  // Отримати публічний URL
  String getPublicUrl() => _publicUrl;

  // Зберегти вибраний сценарій використання
  Future<void> saveUsageScenario(String scenarioName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usageScenarioKey, scenarioName);
  }

  // Отримати збережений сценарій використання
  Future<String?> getSavedUsageScenario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usageScenarioKey);
  }

  // Отримати збережений токен доступу
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Зберегти токен доступу
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  // Отримати ID автопарка
  Future<int> getFleetId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_fleetIdKey) ?? 1; // За замовчуванням 10
  }

  // Зберегти ID автопарка
  Future<void> setFleetId(int fleetId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fleetIdKey, fleetId);
  }
}
