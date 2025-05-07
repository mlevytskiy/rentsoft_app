import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentsoft_app/features/home/screens/home_screen.dart';
import 'package:rentsoft_app/features/auth/screens/admin_confirmation_screen.dart';
import 'package:rentsoft_app/features/user/screens/users_with_ads_screen.dart';

class ResponseViewScreen extends StatelessWidget {
  final dynamic responseData;
  final String? screenTitle;
  final VoidCallback? onClose;

  const ResponseViewScreen({
    super.key, 
    required this.responseData,
    this.screenTitle,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle ?? 'Відповідь сервера'),
        backgroundColor: const Color(0xFF3F5185),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Деталі відповіді сервера:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResponseDetails(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Copy response to clipboard
                    Clipboard.setData(ClipboardData(text: responseData.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Скопійовано в буфер обміну')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Копіювати'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Check if we have a custom close callback
                    if (onClose != null) {
                      // Закриваємо поточний екран і викликаємо callback
                      Navigator.of(context).pop();
                      onClose!();
                      return;
                    }
                    
                    // Standard navigation if no callback provided
                    bool isAdminLoginSuccess = false;
                    
                    if (responseData is Map<String, dynamic>) {
                      // Check for admin user in response data
                      final user = responseData['user'] as Map<String, dynamic>?;
                      
                      if (user != null) {
                        // If user exists and is admin (staff or superuser)
                        final isStaff = user['is_staff'] as bool?;
                        final isSuperuser = user['is_superuser'] as bool?;
                        
                        isAdminLoginSuccess = (isStaff == true || isSuperuser == true);
                      }
                    }
                    
                    // Navigate based on admin status
                    if (isAdminLoginSuccess) {
                      // Navigate to admin confirmation screen with response data
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const AdminConfirmationScreen(),
                          settings: RouteSettings(arguments: responseData),
                        ),
                      );
                    } else if (screenTitle == 'Список користувачів') {
                      // Якщо це екран зі списком користувачів, переходимо на екран з оголошеннями
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const UsersWithAdsScreen(),
                        ),
                      );
                    } else {
                      // Navigate to the home screen
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F5185),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Далі'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseDetails() {
    if (responseData == null) {
      return const Text('Немає даних');
    }

    // Format the response data nicely
    try {
      final formattedJson = _formatJson(responseData);
      return Text(
        formattedJson,
        style: const TextStyle(fontFamily: 'monospace'),
      );
    } catch (e) {
      // Fallback to simple toString if parsing fails
      return Text(responseData.toString());
    }
  }

  String _formatJson(dynamic json) {
    String result = '';
    
    if (json is Map) {
      // Indent and format map elements
      result += '{\n';
      json.forEach((key, value) {
        result += '  "$key": ';
        if (value is Map || value is List) {
          String nested = _formatJson(value);
          // Indent nested content
          nested = nested.split('\n').map((line) => '  $line').join('\n');
          result += '$nested,\n';
        } else if (value is String) {
          result += '"$value",\n';
        } else {
          result += '$value,\n';
        }
      });
      // Remove trailing comma
      if (result.endsWith(',\n')) {
        result = '${result.substring(0, result.length - 2)}\n';
      }
      result += '}';
    } else if (json is List) {
      // Indent and format list elements
      result += '[\n';
      for (var item in json) {
        if (item is Map || item is List) {
          String nested = _formatJson(item);
          nested = nested.split('\n').map((line) => '  $line').join('\n');
          result += '  $nested,\n';
        } else if (item is String) {
          result += '  "$item",\n';
        } else {
          result += '  $item,\n';
        }
      }
      // Remove trailing comma
      if (result.endsWith(',\n')) {
        result = '${result.substring(0, result.length - 2)}\n';
      }
      result += ']';
    } else {
      // Simple value
      result = json.toString();
    }
    
    return result;
  }
}
