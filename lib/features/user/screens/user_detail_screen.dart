import 'package:flutter/material.dart';
import 'package:rentsoft_app/features/auth/screens/response_view_screen.dart';
import 'package:rentsoft_app/features/car/services/car_service.dart';
import 'package:rentsoft_app/features/user/data/car_database.dart';
import 'package:rentsoft_app/features/user/models/car_model.dart';
import 'package:rentsoft_app/features/user/models/user_with_ads_count.dart';
import 'package:rentsoft_app/features/user/repositories/user_repository.dart';
import 'package:rentsoft_app/features/user/screens/user_advertisements_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final UserWithAdsCount user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final UserRepository _userRepository = UserRepository();
  final CarService _carService = CarService(); // Додано CarService
  CarModel? _generatedCar;
  bool _isLoading = false;
  bool _isCreatingAd = false;
  bool _isCreatingBaseValues = false;

  void _generateRandomCar() {
    setState(() {
      _generatedCar = CarDatabase.getRandomCar();
    });
  }

  Future<void> _createAdvertisement() async {
    if (_generatedCar == null) return;

    setState(() {
      _isCreatingAd = true;
    });

    try {
      final response = await _userRepository.createCarAdvertisement(
        widget.user.id,
        _generatedCar!,
      );

      if (mounted) {
        // Додаємо ID користувача для перевірки
        response['user_id'] = widget.user.id;
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResponseViewScreen(
              responseData: response,
              screenTitle: 'Результат створення оголошення',
              onClose: () {
                // Після закриття екрану відповіді перенаправляємо на екран оголошень
                _viewUserAdvertisements();
              },
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
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingAd = false;
        });
      }
    }
  }
  
  void _viewUserAdvertisements() async {
    // Встановлюємо ID користувача для перегляду його оголошень
    await _carService.setSelectedUserId(widget.user.id);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserAdvertisementsScreen(
          user: widget.user,
        ),
      ),
    ).then((_) {
      // Очищаємо вибраний ID користувача при поверненні
      _carService.clearSelectedUserId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.name} ${widget.user.surname}'),
        backgroundColor: const Color(0xFF3F5185),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Інформація про користувача
              _buildUserInfoCard(),
              
              const SizedBox(height: 16),
              
              // Кнопка перегляду оголошень користувача
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _viewUserAdvertisements,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Переглянути оголошення користувача'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Кнопка для створення базових значень
              _buildCreateBaseValuesButton(),
              
              const SizedBox(height: 16),
              
              // Кнопка генерації авто
              _buildGenerateCarButton(),
              
              const SizedBox(height: 24),
              
              // Відображення згенерованого авто
              if (_generatedCar != null) _buildCarInfoCard(),
              
              const SizedBox(height: 24),
              
              // Кнопка створення оголошення
              if (_generatedCar != null) 
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isCreatingAd ? null : _createAdvertisement,
                    icon: _isCreatingAd 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_circle_outline),
                    label: Text(_isCreatingAd 
                      ? 'Створення оголошення...' 
                      : 'Додати оголошення'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F5185),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF3F5185),
                  child: Text(
                    widget.user.name.substring(0, 1), 
                    style: const TextStyle(
                      fontSize: 24, 
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.user.name} ${widget.user.surname}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ID: ${widget.user.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.user.adsCount > 0 
                    ? const Color(0xFF3F5185) 
                    : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Оголошень: ${widget.user.adsCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Метод для створення базових значень на сервері
  Future<void> _createBaseValues() async {
    setState(() {
      _isCreatingBaseValues = true;
    });

    try {
      final response = await _userRepository.createBaseValues();

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResponseViewScreen(
              responseData: response,
              screenTitle: 'Результат створення базових значень',
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
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingBaseValues = false;
        });
      }
    }
  }

  Widget _buildCreateBaseValuesButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isCreatingBaseValues ? null : _createBaseValues,
        icon: _isCreatingBaseValues
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add_box),
        label: Text(_isCreatingBaseValues
            ? 'Створення базових значень...'
            : 'Додати fuel_type, transmission, category, status'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildGenerateCarButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _generateRandomCar,
        icon: const Icon(Icons.car_rental),
        label: const Text('Згенерувати автомобіль'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCarInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Фото авто
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(
              _generatedCar!.photo,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
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
          
          // Деталі авто
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_generatedCar!.brand} ${_generatedCar!.model}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Рік випуску', _generatedCar!.year.toString()),
                _buildDetailRow('Колір', _generatedCar!.color),
                _buildDetailRow('Двигун', '${_generatedCar!.engineVolume} л, ${_generatedCar!.fuelType}'),
                _buildDetailRow('Коробка передач', _generatedCar!.transmission),
                _buildDetailRow('Пробіг', '${_generatedCar!.mileage} км'),
                _buildDetailRow('VIN-код', _generatedCar!.vin),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ціна: ${_generatedCar!.price} грн/день',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
