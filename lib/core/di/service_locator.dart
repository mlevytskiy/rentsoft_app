import 'package:get_it/get_it.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repositories/mock_auth_repository.dart';
import '../api/api_client.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // API Client
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Repositories
  getIt.registerLazySingleton<MockAuthRepository>(() => MockAuthRepository());
  
  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<MockAuthRepository>()));
}
