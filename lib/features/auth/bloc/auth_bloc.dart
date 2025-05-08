import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/api_config_service.dart';
import '../../../core/services/error_handler.dart';
import '../../../core/services/version_service.dart';
import '../models/user_model.dart';
import '../repositories/i_auth_repository.dart';
import '../repositories/mock_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _initialAuthRepository;
  final ApiConfigService _apiConfigService = getIt<ApiConfigService>();
  final VersionService _versionService = getIt<VersionService>();

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
    print('DEBUG: AuthBloc - початок _onCheckStatus');
    emit(AuthLoading());
    try {
      // Перевіряємо, чи змінилася версія додатку
      final hasVersionChanged = await _versionService.hasVersionChanged();
      print('DEBUG: AuthBloc - версія змінилася: $hasVersionChanged');

      if (hasVersionChanged) {
        // Якщо версія змінилася, оновлюємо збережену версію та відправляємо користувача на логін
        await _versionService.updateSavedVersion();
        print('DEBUG: AuthBloc - версію оновлено, перенаправляємо на логін');
        emit(AuthUnauthenticated());
        return;
      }

      final repository = await _getRepository();
      final isLoggedIn = await repository.isLoggedIn();
      print('DEBUG: AuthBloc - isLoggedIn: $isLoggedIn');

      if (isLoggedIn) {
        // Get current user data from storage
        final user = await repository.getCurrentUser();
        print('DEBUG: AuthBloc - user: ${user?.profile?.name ?? "null"}');

        if (user != null) {
          print('DEBUG: AuthBloc - user found, isVerified: ${user.profile?.isVerified ?? false}');

          // Додаткова перевірка - якщо вийшли з системи, але користувач залишився в кеші
          // перевіряємо, чи є валідний токен
          final hasToken = await repository.hasValidToken();
          print('DEBUG: AuthBloc - hasValidToken: $hasToken');

          if (!hasToken) {
            print('DEBUG: AuthBloc - token invalid, emitting AuthUnauthenticated');
            emit(AuthUnauthenticated());
            return;
          }

          // Перевіряємо, чи користувач пройшов верифікацію
          // Якщо верифікований - це існуючий користувач
          // Якщо не верифікований - це новий користувач
          if (user.profile?.isVerified ?? false) {
            print('DEBUG: AuthBloc - emitting AuthAuthenticated.existingUser');
            emit(AuthAuthenticated.existingUser(user));
          } else {
            print('DEBUG: AuthBloc - emitting AuthAuthenticated.newUser');
            emit(AuthAuthenticated.newUser(user));
          }
        } else {
          print('DEBUG: AuthBloc - user null, emitting AuthUnauthenticated');
          emit(AuthUnauthenticated());
        }
      } else {
        print('DEBUG: AuthBloc - not logged in, emitting AuthUnauthenticated');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('DEBUG: AuthBloc - error: ${e.toString()}');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Якщо це адмін-режим, завжди показуємо відповідь сервера
    if (event.isAdmin) {
      try {
        final repository = await _getRepository();
        try {
          final user = await repository.login(
            event.email,
            event.password,
            isAdmin: true,
          );
          
          // Отримуємо сирі дані для відображення
          final Map<String, dynamic> responseData = await _extractUserData(user);
          
          // Додаємо інформацію про адміністратора для відображення
          responseData['is_admin_mode'] = true;
          
          // Зберігаємо відповідь для відображення на екрані
          emit(AuthAdminResponse(responseData));
        } catch (e) {
          // При помилці показуємо екран з відповіддю про помилку
          emit(AuthAdminResponse({'error': e.toString(), 'details': 'Error connecting to auth endpoint'}));
        }
      } catch (e) {
        // Якщо виникла помилка з репозиторієм, все одно показуємо екран з помилкою
        emit(AuthAdminResponse({'error': e.toString(), 'source': 'Repository initialization'}));
      }
    } else {
      try {
        // Стандартний вхід
        final repository = await _getRepository();
        final user = await repository.login(
          event.email,
          event.password,
          isAdmin: false,
        );
        // Явно вказуємо, що користувач існуючий
        emit(AuthAuthenticated.existingUser(user));
      } catch (e) {
        if (e is ApiException && e.authError != null) {
          emit(AuthFailure.fromError(e.authError!));
        } else {
          emit(AuthFailure.fromError(e));
        }
      }
    }
  }
  
  // Допоміжний метод для отримання даних користувача в форматі для відображення
  Future<Map<String, dynamic>> _extractUserData(UserModel user) async {
    try {
      // Спроба отримати збережені дані з secure storage
      final repository = await _getRepository();
      final userData = await repository.getUserData();
      
      if (userData != null) {
        return userData;
      }
      
      // Якщо даних немає, повертаємо базові дані користувача
      return user.toJson();
    } catch (e) {
      // У випадку помилки, повертаємо базові дані користувача
      return user.toJson();
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
      print('DEBUG: Реєстрація успішна, але API не повертає токени. Спробуємо автоматичний вхід');
      
      // Після успішної реєстрації виконуємо автоматичний вхід
      try {
        // Виконуємо вхід з тими ж обліковими даними
        final loggedInUser = await repository.login(
          event.email,
          event.password,
          isAdmin: false,
        );
        
        // Передаємо інформацію про нового користувача
        print('DEBUG: Автоматичний вхід після реєстрації успішний');
        print('DEBUG: Реєстрація користувача - встановлюємо isNewUser=true');
        print('DEBUG: Профіль користувача isVerified=${loggedInUser.profile?.isVerified ?? false}');
        
        // Явно використовуємо фабричний метод для нового користувача
        emit(AuthAuthenticated.newUser(loggedInUser));
      } catch (loginError) {
        // Якщо вхід після реєстрації не вдався, все одно повертаємо успіх реєстрації
        print('DEBUG: Помилка при автоматичному вході після реєстрації: $loginError');
        // Все одно вважаємо реєстрацію успішною
        emit(AuthAuthenticated.newUser(user));
      }
    } catch (e) {
      if (e is ApiException && e.authError != null) {
        emit(AuthFailure.fromError(e.authError!));
      } else {
        emit(AuthFailure.fromError(e));
      }
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

      // Явно переводимо додаток в неавторизований стан
      // без будь-яких додаткових прапорців для уникнення плутанини з isNewUser
      print('DEBUG: Logging out - emitting AuthUnauthenticated');
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
