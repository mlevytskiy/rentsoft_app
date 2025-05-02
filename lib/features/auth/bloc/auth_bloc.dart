import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/api_config_service.dart';
import '../repositories/i_auth_repository.dart';
import '../repositories/mock_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _initialAuthRepository;
  final ApiConfigService _apiConfigService = getIt<ApiConfigService>();
  
  AuthBloc(this._initialAuthRepository) : super(AuthInitial()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
  }

  // Отримуємо актуальний репозиторій на основі поточних налаштувань
  Future<IAuthRepository> _getRepository() async {
    final isOfflineMode = await _apiConfigService.isOfflineMode();
    
    if (isOfflineMode) {
      // Якщо офлайн режим, використовуємо MockAuthRepository
      return getIt<MockAuthRepository>();
    }
    
    // В іншому випадку використовуємо початковий репозиторій
    return _initialAuthRepository;
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final repository = await _getRepository();
      final isLoggedIn = await repository.isLoggedIn();
      if (isLoggedIn) {
        // Get current user data from storage
        final user = await repository.getCurrentUser();
        if (user != null) {
          // Перевіряємо, чи користувач пройшов верифікацію
          // Якщо верифікований - це існуючий користувач 
          // Якщо не верифікований - це новий користувач
          if (user.profile.isVerified) {
            emit(AuthAuthenticated.existingUser(user));
          } else {
            emit(AuthAuthenticated.newUser(user));
          }
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final repository = await _getRepository();
      final user = await repository.login(
        event.email,
        event.password,
      );
      // Явно вказуємо, що користувач існуючий
      emit(AuthAuthenticated.existingUser(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final repository = await _getRepository();
      final user = await repository.register(
        event.email,
        event.password,
        event.name,
        event.surname,
      );
      // Відмічаємо, що користувач новий і потребує верифікації
      print('DEBUG: Реєстрація користувача - встановлюємо isNewUser=true');
      print('DEBUG: Профіль користувача isVerified=${user.profile.isVerified}');
      // Явно використовуємо фабричний метод для нового користувача
      emit(AuthAuthenticated.newUser(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final repository = await _getRepository();
      await repository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
