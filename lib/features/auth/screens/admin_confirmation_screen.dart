import 'package:flutter/material.dart';
import 'package:rentsoft_app/core/services/api_config_service.dart';
import 'package:rentsoft_app/features/auth/screens/response_view_screen.dart';
import 'package:rentsoft_app/features/user/repositories/user_repository.dart';

class AdminConfirmationScreen extends StatefulWidget {
  const AdminConfirmationScreen({super.key});

  @override
  State<AdminConfirmationScreen> createState() => _AdminConfirmationScreenState();
}

class _AdminConfirmationScreenState extends State<AdminConfirmationScreen> {
  final ApiConfigService _apiConfigService = ApiConfigService();
  Map<String, dynamic>? _responseData;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Отримуємо дані відповіді від попереднього екрану
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _responseData = args;
      _saveTokenFromResponse();
    }
  }
  
  // Зберігаємо токен доступу з відповіді
  Future<void> _saveTokenFromResponse() async {
    if (_responseData != null) {
      final accessToken = _responseData!['access'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        await _apiConfigService.setToken(accessToken);
        print('Токен доступу збережено: ${accessToken.substring(0, 10)}...');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Адміністратор'),
        backgroundColor: const Color(0xFF3F5185),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Color(0xFF3F5185),
            ),
            const SizedBox(height: 24),
            const Text(
              'Тепер ви адміністратор',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Завантаження даних користувачів...')),
                  );
                  
                  // Переконуємося, що токен збережено
                  if (_responseData != null) {
                    final accessToken = _responseData!['access'] as String?;
                    if (accessToken != null && accessToken.isNotEmpty) {
                      await _apiConfigService.setToken(accessToken);
                    }
                  }
                  
                  // Create repository instance
                  final userRepository = UserRepository();
                  
                  try {
                    // Make API request to get all users
                    final response = await userRepository.getAllUsers();
                    
                    if (mounted) {
                      // Navigate to response view screen with user data
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ResponseViewScreen(
                            responseData: response,
                            screenTitle: 'Список користувачів',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Помилка: ${e.toString()}')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F5185),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                child: const Text('Далі'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
