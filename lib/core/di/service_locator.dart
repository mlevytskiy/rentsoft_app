import 'package:get_it/get_it.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/repositories/mock_auth_repository.dart';
import '../api/api_client.dart';
import '../services/api_config_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services - реєструємо сервіси
  getIt.registerLazySingleton<ApiConfigService>(() => ApiConfigService());
  
  // API Client
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Repositories - реєструємо обидва репозиторії
  getIt.registerLazySingleton<MockAuthRepository>(() => MockAuthRepository());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<ApiClient>()));
  
  // BLoCs - AuthBloc автоматично вибере правильний репозиторій
  final apiConfigService = getIt<ApiConfigService>();
  final isOfflineMode = await apiConfigService.isOfflineMode();
  
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
