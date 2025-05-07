import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/response_view_screen.dart';
import 'features/auth/screens/verification_screen.dart';
import 'features/home/screens/home_screen.dart';

// Global navigator key for accessing navigation context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global variable to store the current tab index
int currentTabIndex = 1; // Default to search tab (index 1)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Очікуємо завершення ініціалізації залежностей
  await setupDependencies();

  runApp(
    BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(AuthCheckStatusEvent()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RentSoft',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      // Маршрути додатка
      routes: {
        '/login': (context) => const AuthScreen(),
      },
      home: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) {
          print('DEBUG: BlocBuilder buildWhen previous=${previous.runtimeType}, current=${current.runtimeType}');
          // Завжди перебудовуємо, щоб коректно реагувати на всі зміни стану
          return true;
        },
        builder: (context, state) {
          print('DEBUG: BlocBuilder building with state=${state.runtimeType}');

          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is AuthAuthenticated) {
            // Перевіряємо, чи це новий користувач
            if (state.isNewUser) {
              print('DEBUG: Main.dart - перенаправлення на екран верифікації');
              // Затримка для уникнення помилок під час побудови
              Future.microtask(() {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => VerificationScreen(user: state.user),
                  ),
                );
              });
              // Покажемо спіннер поки йде перенаправлення
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            // Існуючий користувач - на головний екран
            return const HomeScreen();
          }

          // Обробка стану AuthAdminResponse - показуємо екран з відповіддю
          if (state is AuthAdminResponse) {
            print('DEBUG: Main.dart - відображення екрану з відповіддю адміністратора');
            return ResponseViewScreen(responseData: state.responseData);
          }

          // Стан AuthUnauthenticated або будь-який інший - показуємо екран авторизації
          print('DEBUG: Main.dart - відображення екрану авторизації');
          return const AuthScreen();
        },
      ),
    );
  }
}
