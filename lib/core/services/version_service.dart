import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Сервіс для роботи з версіями додатку
class VersionService {
  static const String _lastVersionKey = 'last_app_version';
  
  // Сервіс-сінглтон
  static final VersionService _instance = VersionService._internal();
  factory VersionService() => _instance;
  VersionService._internal();
  
  /// Перевірити, чи змінилася версія додатку
  /// Повертає true, якщо версія змінилася або це перший запуск
  Future<bool> hasVersionChanged() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final lastVersion = prefs.getString(_lastVersionKey);
    
    debugPrint('[VersionService] Поточна версія: $currentVersion, Збережена: $lastVersion');
    
    // Якщо збереженої версії немає або вона відрізняється від поточної
    return lastVersion == null || lastVersion != currentVersion;
  }
  
  /// Оновити збережену версію
  Future<void> updateSavedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    
    await prefs.setString(_lastVersionKey, currentVersion);
    debugPrint('[VersionService] Збережено нову версію: $currentVersion');
  }
  
  /// Отримати поточну версію додатку
  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
