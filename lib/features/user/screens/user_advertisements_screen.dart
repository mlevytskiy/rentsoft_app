import 'package:flutter/material.dart';
import 'package:rentsoft_app/features/auth/screens/response_view_screen.dart';
import 'package:rentsoft_app/features/user/models/user_with_ads_count.dart';
import 'package:rentsoft_app/features/user/repositories/user_repository.dart';

class UserAdvertisementsScreen extends StatefulWidget {
  final UserWithAdsCount user;

  const UserAdvertisementsScreen({super.key, required this.user});

  @override
  State<UserAdvertisementsScreen> createState() => _UserAdvertisementsScreenState();
}

class _UserAdvertisementsScreenState extends State<UserAdvertisementsScreen> {
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = true;
  List<dynamic> _advertisements = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
  }

  Future<void> _loadAdvertisements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _userRepository.getUserAdvertisements(widget.user.id);
      
      if (response['status_code'] == 200) {
        setState(() {
          // Перевіряємо формат відповіді, оскільки він може відрізнятися
          print('DEBUG: UserAdvertisementsScreen - Структура відповіді: ${response.keys.toString()}');
          
          if (response.containsKey('data')) {
            var data = response['data'];
            print('DEBUG: UserAdvertisementsScreen - Тип data: ${data.runtimeType}');
            
            // API повертає структуру з полем data, яке містить масив оголошень
            
            // Надрукуємо детальну інформацію про структуру
            if (data is Map) {
              print('DEBUG: Ключі в data: ${data.keys.toString()}');
            }
            
            if (data is List) {
              // Прямий масив даних
              _advertisements = data;
              print('DEBUG: Використовуємо data як List');
            } else if (data is Map && data.containsKey('results')) {
              // Об'єкт з полем results, яке містить масив
              _advertisements = data['results'] as List;
              print('DEBUG: Використовуємо data["results"]');
            } else if (data is Map && data.containsKey('data')) {
              // Структура з вкладеним полем data для вкладених даних
              _advertisements = data['data'] as List;
              print('DEBUG: Використовуємо data["data"]');
            } else if (data is Map) {
              // Прямий доступ до поля JSON відповіді для нового API
              if (data.containsKey('total_items') && data.containsKey('total_pages')) {
                // Це відповідь від нового API з пагінацією
                print('DEBUG: Виявлено структуру з пагінацією, total_items: ${data['total_items']}');
                _advertisements = data['data'] as List;
              } else {
                // Загальний випадок: просто використовуємо об'єкт як масив
                _advertisements = [data];
                print('DEBUG: Використовуємо data як одиночний об\'u0454кт');
              }
            } else {
              _advertisements = [];
              print('DEBUG: Не вдалося розпізнати формат даних');
            }
          } else {
            _advertisements = [];
          }
          
          print('DEBUG: UserAdvertisementsScreen - Кількість оголошень: ${_advertisements.length}');
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Помилка завантаження оголошень: ${response['error_message'] ?? 'Невідома помилка'}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Помилка: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _viewAdvertisementDetails(dynamic advertisement) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResponseViewScreen(
          responseData: {'status_code': 200, 'data': advertisement},
          screenTitle: 'Деталі оголошення',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Оголошення ${widget.user.name} ${widget.user.surname}'),
        backgroundColor: const Color(0xFF3F5185),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdvertisements,
            tooltip: 'Оновити список',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAdvertisements,
              icon: const Icon(Icons.refresh),
              label: const Text('Спробувати знову'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F5185),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_advertisements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.car_rental,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'У цього користувача немає оголошень',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Створіть нове оголошення на екрані деталей користувача',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAdvertisements,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _advertisements.length,
        itemBuilder: (context, index) {
          final advertisement = _advertisements[index];
          return _buildAdvertisementCard(advertisement);
        },
      ),
    );
  }

  Widget _buildAdvertisementCard(dynamic advertisement) {
    // Отримуємо дані з оголошення
    final String carBrand = advertisement['car_brand'] ?? 'Невідома марка';
    final String carModel = advertisement['car_model'] ?? 'Невідома модель';
    final dynamic price = advertisement['price'];
    final String priceFormatted = price != null ? price.toString() : '0.00';
    final String createdAt = advertisement['created_at'] ?? 'Невідома дата';
    
    // Перевіряємо чи доступні фото
    final List<dynamic> photos = advertisement['photos'] != null && advertisement['photos'] is List
        ? advertisement['photos'] as List<dynamic>
        : [];
    
    final String photoUrl = photos.isNotEmpty && photos[0] != null && photos[0]['photo'] != null
        ? photos[0]['photo'] as String
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewAdvertisementDetails(advertisement),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото авто (якщо є)
            if (photoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  photoUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.car_crash,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            
            // Якщо фото немає, показуємо заглушку
            if (photoUrl.isEmpty)
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            
            // Інформація про оголошення
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$carBrand $carModel',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ціна: $priceFormatted грн',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Створено: ${createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Власник: ${widget.user.name} ${widget.user.surname}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Кнопка перегляду деталей
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _viewAdvertisementDetails(advertisement),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Переглянути деталі'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3F5185),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
