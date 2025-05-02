import 'package:get_it/get_it.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/repositories/mock_auth_repository.dart';
import '../api/api_client.dart';
import '../services/api_config_service.dart';
import '../services/version_service.dart';
import '../services/scenario_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services - реєструємо сервіси
  final apiConfigService = ApiConfigService();
  getIt.registerSingleton<ApiConfigService>(apiConfigService);
  
  // Сервіс для роботи з версіями
  final versionService = VersionService();
  getIt.registerSingleton<VersionService>(versionService);
  
  // Сервіс для режимів роботи з автопарками
  final scenarioService = ScenarioService();
  getIt.registerSingleton<ScenarioService>(scenarioService);

  // Отримуємо конфігурацію API та перевіряємо режим
  final isOfflineMode = await apiConfigService.isOfflineMode();
  
  // API Client
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Repositories - реєструємо обидва репозиторії
  getIt.registerLazySingleton<MockAuthRepository>(() => MockAuthRepository());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<ApiClient>()));
  
  // BLoCs - AuthBloc автоматично вибере правильний репозиторій
  // При створенні блоку передаємо репозиторій за замовчуванням,
  // але в подальшому блок сам динамічно перевірятиме режим
  getIt.registerFactory<AuthBloc>(() {
    if (isOfflineMode) {
      return AuthBloc(getIt<MockAuthRepository>());
    } else {
      return AuthBloc(getIt<AuthRepository>());
    }
  });
}
