import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/auth/screens/verification_screen.dart'; // Added import for VerificationScreen

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
      home: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) {
          // Вимикаємо це правило, щоб дозволити перебудову для нових користувачів
          return true;
        },
        builder: (context, state) {
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

          return const AuthScreen();
        },
      ),
    );
  }
}
