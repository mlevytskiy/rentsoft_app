import 'package:get_it/get_it.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../api/api_client.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // API Client
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<ApiClient>()));
  
  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
}
