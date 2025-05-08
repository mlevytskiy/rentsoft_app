import 'package:flutter/material.dart';
import 'package:rentsoft_app/features/auth/screens/response_view_screen.dart';
import 'package:rentsoft_app/features/user/repositories/user_repository.dart';

class AllAdvertisementsScreen extends StatefulWidget {
  const AllAdvertisementsScreen({super.key});

  @override
  State<AllAdvertisementsScreen> createState() => _AllAdvertisementsScreenState();
}

class _AllAdvertisementsScreenState extends State<AllAdvertisementsScreen> {
  final UserRepository _userRepository = UserRepository();
  List<dynamic> _advertisements = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAllAdvertisements();
  }

  Future<void> _loadAllAdvertisements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _userRepository.getAllAdvertisements();
      
      if (response['status_code'] == 200) {
        setState(() {
          // Перевіряємо формат відповіді, оскільки він може відрізнятися
          if (response['data'] is List) {
            _advertisements = response['data'];
          } else if (response['data'] is Map && response['data'].containsKey('results')) {
            _advertisements = response['data']['results'] as List;
          } else {
            _advertisements = [];
          }
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
        title: const Text('Всі оголошення'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllAdvertisements,
            tooltip: 'Оновити',
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
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllAdvertisements,
              child: const Text('Спробувати знову'),
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
            const Icon(Icons.car_rental, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Немає доступних оголошень',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllAdvertisements,
              child: const Text('Оновити'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllAdvertisements,
      child: ListView.builder(
        itemCount: _advertisements.length,
        itemBuilder: (context, index) {
          final advertisement = _advertisements[index];
          return _buildAdvertisementCard(advertisement);
        },
      ),
    );
  }

  Widget _buildAdvertisementCard(dynamic advertisement) {
    // Отримуємо дані оголошення
    final String carBrand = advertisement['car_brand'] ?? 'Невідома марка';
    final String carModel = advertisement['car_model'] ?? 'Невідома модель';
    final dynamic price = advertisement['price'];
    final String priceText = price != null ? '$price грн' : 'Ціна не вказана';
    final String createdAt = advertisement['created_at'] ?? 'Невідома дата';
    final DateTime? dateTime = createdAt != 'Невідома дата' ? DateTime.parse(createdAt) : null;
    final String formattedDate = dateTime != null ? '${dateTime.day}.${dateTime.month}.${dateTime.year}' : 'Невідома дата';
    final List<dynamic> photos = advertisement['photos'] != null && advertisement['photos'] is List
        ? advertisement['photos'] as List<dynamic>
        : [];

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 3,
      child: InkWell(
        onTap: () => _viewAdvertisementDetails(advertisement),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото (якщо є)
            if (photos.isNotEmpty && photos[0]['photo'] != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(photos[0]['photo']),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(
                    Icons.car_rental,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Марка та модель
                  Text(
                    '$carBrand $carModel',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Ціна
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Дата створення
                  Text(
                    'Додано: $formattedDate',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Кнопка "Детальніше"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _viewAdvertisementDetails(advertisement),
                      child: const Text('Детальніше'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
