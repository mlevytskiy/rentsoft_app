import '../di/service_locator.dart';
import 'api_config_service.dart';

enum FleetMode {
  all,      // Доступні всі автопарки
  single    // Тільки Автопарк 1
}

class ScenarioService {
  final ApiConfigService _apiConfigService = getIt<ApiConfigService>();
  
  // Сервіс-сінглтон
  static final ScenarioService _instance = ScenarioService._internal();
  factory ScenarioService() => _instance;
  ScenarioService._internal();
  
  // Інформація про Автопарк 1
  final String fleetName = 'Автопарк 1';
  final String fleetAddress = 'вул. Хрещатик, 1, Київ, 01001';
  
  // Отримати поточний режим відображення автопарків
  Future<FleetMode> getFleetMode() async {
    final savedScenario = await _apiConfigService.getSavedUsageScenario();
    
    // За замовчуванням показуємо всі автопарки
    if (savedScenario == null) return FleetMode.all;
    
    // Перевіряємо вибраний сценарій
    if (savedScenario == 'UsageScenario.singleFleet') {
      return FleetMode.single;
    }
    
    return FleetMode.all;
  }
}
