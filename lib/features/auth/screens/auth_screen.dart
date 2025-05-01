import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_client.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/api_config_service.dart';
import '../../secret/screens/secret_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../services/mock_data_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _apiConfigService = ApiConfigService();
  final _apiClient = getIt<ApiClient>();

  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _showSecretButton = false; // Контролює видимість жовтої кнопки

  // Для відстеження послідовних натискань
  final List<DateTime> _tapTimestamps = [];

  @override
  void initState() {
    super.initState();
    _refreshConfiguration();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshConfiguration();
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLogin) {
      context.read<AuthBloc>().add(
            AuthLoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            AuthRegisterEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
              surname: _surnameController.text.trim(),
            ),
          );
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

    // Show snackbar with success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Форму заповнено випадковими даними'),
        duration: Duration(seconds: 2),
      ),
    );
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
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
                            children: [
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
                                'Тут ви можете орендувати машину',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.black87,
                                ),
                              ),
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
                                  padding: const EdgeInsets.all(16),
                                ),
                                child: const Icon(
                                  Icons.auto_fix_high,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              _showSecretButton
                                  ? ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const SecretScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber,
                                        foregroundColor: Colors.white,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(16),
                                      ),
                                      child: const Icon(
                                        Icons.vpn_key,
                                        size: 24,
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
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (!_isLogin && value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

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
                          borderRadius: BorderRadius.circular(8),
                        ),
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
