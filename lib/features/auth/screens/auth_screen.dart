import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentsoft_app/features/home/screens/home_screen.dart';

import '../../../core/api/api_client.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/api_config_service.dart';
import '../../../core/services/scenario_service.dart';
import '../../secret/screens/secret_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../services/mock_data_service.dart';
import 'response_view_screen.dart'; // Доданий імпорт нового екрану
import 'verification_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _apiConfigService = ApiConfigService();
  final _apiClient = getIt<ApiClient>();
  final _scenarioService = getIt<ScenarioService>();

  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _isAdminMode = false; // Додана змінна для адмін-режиму
  bool _showSecretButton = false; // Контролює видимість жовтої кнопки
  FleetMode _fleetMode = FleetMode.all; // За замовчуванням показуємо всі автопарки

  // Для відстеження послідовних натискань
  final List<DateTime> _tapTimestamps = [];

  @override
  void initState() {
    super.initState();
    // Реєструємо спостерігач за життєвим циклом
    WidgetsBinding.instance.addObserver(this);
    _refreshConfiguration();
    _loadFleetMode();
  }

  @override
  void dispose() {
    // Скасовуємо реєстрацію спостерігача
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  // Додано метод життєвого циклу для оновлення при поверненні на екран
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Викликається при зміні стану життєвого циклу додатка
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Якщо додаток відновлено, оновлюємо налаштування
      _loadFleetMode();
    }
  }

  // Додано метод для реагування на зміни маршрутів Flutter
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //TODO@m.levytskyi: this refresh brake admin functionality. That's why I commented it
    // _refreshConfiguration();
    // Оновлюємо при кожній зміні залежностей (включає повернення на екран)
    // _loadFleetMode();
    // print('[AuthScreen] Оновлюємо режим відображення при зміні залежностей');
  }

  @override
  void didUpdateWidget(covariant AuthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadFleetMode(); // Оновлюємо режим відображення при поверненні на екран
  }

  // Оновлює конфігурацію API при показі екрану
  Future<void> _refreshConfiguration() async {
    await _apiClient.refreshBaseUrl();
    // Перевіряємо режим після оновлення URL
    final isOfflineMode = await _apiConfigService.isOfflineMode();
    print('[AuthScreen] 🌐 Режим роботи: ${isOfflineMode ? 'Без інтернету' : 'З інтернетом'}');

    // Оновлюємо AuthBloc тільки якщо контекст доступний
    if (mounted && context.mounted) {
      context.read<AuthBloc>().add(AuthCheckStatusEvent());
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_isLogin) {
        context.read<AuthBloc>().add(
              AuthLoginEvent(
                email: _emailController.text,
                password: _passwordController.text,
                isAdmin: _isAdminMode, // Передаємо флаг адміна
              ),
            );
      } else {
        // При реєстрації нового користувача
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final name = _nameController.text.trim();
        final surname = _surnameController.text.trim();

        // Додаємо подію реєстрації в AuthBloc
        context.read<AuthBloc>().add(
              AuthRegisterEvent(
                email: email,
                password: password,
                name: name,
                surname: surname,
              ),
            );
      }
    }
  }

  void _fillWithMockData() {
    // Get random mock user data
    final mockUser = MockDataService.getRandomUser();

    // Fill all form fields regardless of mode
    _emailController.text = mockUser.email;
    _passwordController.text = mockUser.password;
    _nameController.text = mockUser.firstName;
    _surnameController.text = mockUser.lastName;

    // Прибрано Snackbar з повідомленням про заповнення випадковими даними
  }

  void _handleTitleTap() {
    final now = DateTime.now();

    // Додаємо поточний час натискання
    _tapTimestamps.add(now);

    // Залишаємо тільки натискання за останні 2 секунди
    _tapTimestamps.removeWhere((timestamp) => now.difference(timestamp).inSeconds > 2);

    // Перевіряємо, чи було 5 натискань протягом останніх 2 секунд
    if (_tapTimestamps.length >= 5) {
      setState(() {
        // Перемикаємо видимість кнопки (якщо видно - ховаємо, якщо схована - показуємо)
        _showSecretButton = !_showSecretButton;
        // Очищаємо список натискань після досягнення мети
        _tapTimestamps.clear();
      });
    }
  }

  // Завантаження поточного режиму відображення автопарків
  Future<void> _loadFleetMode() async {
    if (!mounted) return; // Перевіряємо, чи віджет ще в дереві

    final fleetMode = await _scenarioService.getFleetMode();

    // Виводимо режим для дебагу
    print('[AuthScreen] Поточний режим автопарків: $fleetMode');

    if (mounted) {
      setState(() {
        _fleetMode = fleetMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAdminResponse) {
            // Перенаправляємо на екран з відповіддю сервера
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ResponseViewScreen(responseData: state.responseData),
              ),
            );
          } else if (state is AuthFailure) {
            // Clear any previous SnackBars
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            
            if (state.hasFieldErrors) {
              // Update form fields with API errors
              final Map<String, List<String>> fieldErrors = state.fieldErrors;
              
              // Handle email-specific errors
              if (fieldErrors.containsKey('email')) {
                _emailController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _emailController.text.length),
                );
              }
              
              // Display full error message in SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.allErrors),
                  backgroundColor: Colors.red[700],
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Закрити',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            } else {
              // Show simple error for non-field errors
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red[700],
                ),
              );
            }
          } else if (state is AuthAuthenticated && state.isNewUser) {
            print('DEBUG: User registered as new user, navigating to verification screen');
            print('DEBUG: User data: ${state.user.email}, isVerified=${state.user.profile?.isVerified}');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => VerificationScreen(user: state.user),
              ),
            );
          } else if (state is AuthAuthenticated && !state.isNewUser) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF3F5185)),
                  SizedBox(height: 16),
                  Text(
                    'Завантаження...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Logo or App name with buttons positioned on top
                    Stack(
                      children: [
                        // Title and subtitle in the center
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Іконка
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/frame.png',
                                    width: 72,
                                    height: 72,
                                  ),
                                  Image.asset(
                                    'assets/images/auth_logo.png',
                                    width: 27,
                                    height: 27,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Заголовок залежно від режиму флоту
                              if (_fleetMode == FleetMode.all) ...[
                                // Стандартний заголовок для всіх автопарків
                                GestureDetector(
                                  onTap: _handleTitleTap,
                                  child: const Text(
                                    'RentSoft',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Оренда машин в Україні',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.black87,
                                  ),
                                ),
                              ] else ...[
                                // Заголовок для одного автопарку
                                GestureDetector(
                                  onTap: _handleTitleTap,
                                  child: Text(
                                    _scenarioService.fleetName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1B21),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Оренда машин',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF44464F),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _scenarioService.fleetAddress,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF44464F),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Buttons positioned at the top-right corner
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: _fillWithMockData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(4),
                                ),
                                child: const Icon(
                                  Icons.auto_fix_high,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 16),
                              _showSecretButton
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        // Відкриваємо Secret Screen з очікуванням завершення
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const SecretScreen(),
                                          ),
                                        );

                                        // Оновлюємо дані після повернення з Secret Screen
                                        if (mounted) {
                                          await _loadFleetMode();
                                          print('[AuthScreen] Оновлено режим після повернення з Secret Screen');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber,
                                        foregroundColor: Colors.white,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                      child: const Icon(
                                        Icons.vpn_key,
                                        size: 18,
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Будь ласка, введіть пароль';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Checkbox for admin mode - visible only in login mode
                    if (_isLogin) ...[
                      Row(
                        children: [
                          Checkbox(
                            value: _isAdminMode,
                            onChanged: (value) {
                              setState(() {
                                _isAdminMode = value ?? false;

                                // Автоматично заповнюємо поля для адміна
                                if (_isAdminMode) {
                                  _emailController.text = 'admin@gmail.com';
                                  _passwordController.text = 'Notfoundpass1!';
                                } else {
                                  // Якщо знято галочку, очищаємо поля
                                  _emailController.text = '';
                                  _passwordController.text = '';
                                }
                              });
                            },
                            activeColor: const Color(0xFF3F5185),
                          ),
                          const Text('Увійти як адміністратор'),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Registration fields
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Ім'я",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Будь ласка, введіть ім'я";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _surnameController,
                        decoration: const InputDecoration(
                          labelText: 'Прізвище',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Будь ласка, введіть прізвище';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F5185), // Navy blue color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(
                        _isLogin ? 'УВІЙТИ' : 'ЗАРЕЄСТРУВАТИСЯ',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Toggle Button
                    TextButton(
                      onPressed: _toggleAuthMode,
                      child: Text(
                        _isLogin ? 'Немає акаунту? Зареєструватися' : 'Вже маєте акаунт? Увійти',
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Текст про політику конфіденційності - завжди видимий
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          color: Color(0xFF585F72),
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(text: 'Реєстуючись, я погоджуюся з '),
                          TextSpan(
                            text: 'Умовами користування',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFF625B71),
                            ),
                          ),
                          TextSpan(text: ' та '),
                          TextSpan(
                            text: 'Політикою конфіденційності',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFF625B71),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
