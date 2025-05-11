import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/scenario_service.dart';
import '../models/car_model.dart';
import '../services/car_service.dart'; // Import CarService

class CarDetailScreen extends StatefulWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  // Selected rental period dates
  DateTime? startDate;
  DateTime? endDate;
  
  // Scenario service для перевірки режиму автопарків
  final _scenarioService = getIt<ScenarioService>();
  FleetMode _fleetMode = FleetMode.all;

  // Selected rental options
  String selectedRentalType = 'Тижнева'; // Default rental type
  String selectedPaymentType = 'Щотижнево'; // Default payment type
  bool isFavorite = false;
  bool _showCarParkContacts = false; // Flag to toggle contact info visibility
  bool _isBooked = false; // Booking status
  bool _isLoading = false; // Loading state

  // Car park contact information
  final Map<String, Map<String, String>> _carParkContacts = {
    'Автопарк 1': {'address': 'м. Львів, вул. Чорновола 36/5', 'phone': '+380 (67) 123-45-67'},
    'Автопарк 2': {'address': 'м. Київ, вул. Хрещатик 14', 'phone': '+380 (50) 987-65-43'},
    'Автопарк 3': {'address': 'м. Одеса, вул. Дерибасівська 22', 'phone': '+380 (63) 555-77-88'},
  };

  @override
  void initState() {
    super.initState();
    // Set default dates (e.g., today and a week from today)
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, now.day, 10, 30);
    endDate = DateTime(now.year, now.month, now.day + 7, 9, 0);

    // Check if car is already booked
    final carService = CarService();
    _isBooked = carService.isCarBooked(widget.car.id);
    
    // Завантажуємо режим відображення автопарків
    _loadFleetMode();
  }
  
  // Завантаження режиму відображення автопарків
  Future<void> _loadFleetMode() async {
    final fleetMode = await _scenarioService.getFleetMode();
    setState(() {
      _fleetMode = fleetMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(widget.car.fullName),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildCarImages(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarInfoSection(),
                    const Divider(height: 16),
                    _buildRentalTypeSection(),
                    const Divider(height: 16),
                    _buildPaymentSection(),
                    const Divider(height: 16),
                    _buildRentalPeriodSection(),
                    const SizedBox(height: 12),
                    _buildPriceAndRentButton(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCarImages() {
    // Mock additional car images
    final List<String> images = [
      widget.car.imageUrl,
      'https://cdn3.riastatic.com/photosnew/auto/photo/ford_mustang__478893063f.jpg',
    ];

    final carParkInfo = _carParkContacts[widget.car.carPark];

    return Stack(
      children: [
        SizedBox(
          height: 147,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Image.network(
                  images[0],
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        images.length > 1 ? images[1] : images[0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCarParkContacts = !_showCarParkContacts;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                          ),
                          alignment: Alignment.center,
                          // Показуємо кнопку інформації про автопарк тільки коли всі автопарки доступні
                          child: _fleetMode == FleetMode.all 
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _showCarParkContacts ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.black54,
                                    ),
                                    const Text(
                                      'Контакти',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                )
                              : const Icon(
                                  Icons.photo,
                                  color: Colors.black54,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Car Park Information
        Positioned(
          top: 8.0,
          right: 8.0,
          child: _fleetMode == FleetMode.all
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _showCarParkContacts = !_showCarParkContacts;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.car.carPark,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showCarParkContacts ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
        ),
        // Car Park Contact Details popup
        if (_showCarParkContacts && carParkInfo != null)
          Positioned(
            top: 40,
            right: 8,
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          carParkInfo['address'] ?? 'No address',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        carParkInfo['phone'] ?? 'No phone',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCarInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Про автомобіль',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildSpecChip(Icons.directions_car, 'Седан'),
            _buildSpecChip(Icons.airline_seat_recline_normal, '${widget.car.seats}'),
            _buildSpecChip(Icons.speed, '200 км'),
            _buildSpecChip(Icons.local_gas_station, '150 л'),
            _buildSpecChip(Icons.local_gas_station, widget.car.fuelType),
            _buildSpecChip(Icons.business, widget.car.carPark),
            _buildSpecChip(Icons.settings, 'Механічна КП'),
            _buildSpecChip(Icons.settings, 'Автоматична КП'),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecChip(IconData icon, String label) {
    return Chip(
      backgroundColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      avatar: Icon(icon, size: 16),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildRentalTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Оренда',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6, 
          runSpacing: 4,
          children: [
            _buildSelectionChip('Тижнева', 'Тижнева'),
            _buildSelectionChip('Подобова', 'Подобова'),
            _buildSelectionChip('Погодинна', 'Погодинна'),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactSelectionChip(String label, String value) {
    final isSelected = value == selectedRentalType || value == selectedPaymentType;

    return FilterChip(
      selected: isSelected,
      backgroundColor: Colors.grey.shade200,
      selectedColor: const Color(0xFFD7DDF3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      onSelected: (selected) {
        setState(() {
          if (value == 'Тижнева' || value == 'Подобова' || value == 'Погодинна') {
            selectedRentalType = value;
          }
        });
      },
      showCheckmark: false,
    );
  }

  Widget _buildSelectionChip(String label, String value, {bool hasIcon = false, IconData? icon}) {
    final isSelected = value == selectedRentalType || value == selectedPaymentType;

    return FilterChip(
      selected: isSelected,
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.grey.shade300,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      avatar: hasIcon && icon != null ? Icon(icon, size: 14) : null,
      label: Text(label, style: const TextStyle(fontSize: 12)),
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      onSelected: (selected) {
        setState(() {
          if (value == 'Тижнева' || value == 'Подобова' || value == 'Погодинна') {
            selectedRentalType = value;
          } else {
            selectedPaymentType = value;
          }
        });
      },
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Оплата',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildPaymentInfoChip('Щотижнево', Icons.update),
            _buildPaymentInfoChip('Застава', Icons.shield),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentInfoChip(String label, IconData icon) {
    return Chip(
      backgroundColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      avatar: Icon(icon, size: 16),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildRentalPeriodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Період оренди',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.arrow_outward, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  _formatDate(startDate),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            TextButton(
              onPressed: _showDateTimePicker,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Змінити', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.arrow_downward, size: 14, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              _formatDate(endDate),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceAndRentButton() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        // Price section
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const WidgetSpan(
                      child: Text('₴', style: TextStyle(fontSize: 18)),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    TextSpan(
                      text: ' ${widget.car.pricePerWeek}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '/тиждень',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Button section
        _isLoading
            ? const SizedBox(
                height: 36,
                width: 36,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : ElevatedButton(
                onPressed: _isBooked ? _cancelBooking : _bookCar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBooked ? Colors.red.shade700 : const Color(0xFF3F5185),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isBooked ? 'Відмінити бронювання' : 'Орендувати',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString();
    final months = [
      'Січня',
      'Лютого',
      'Березня',
      'Квітня',
      'Травня',
      'Червня',
      'Липня',
      'Серпня',
      'Вересня',
      'Жовтня',
      'Листопада',
      'Грудня'
    ];
    final month = months[date.month - 1];
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$day $month, $time';
  }

  void _showDateTimePicker() async {
    // Показуємо спочатку picker для дати початку оренди
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Виберіть дату початку оренди',
    );
    
    if (pickedStartDate != null) {
      // Якщо вибрали дату початку, показуємо picker для часу початку
      final TimeOfDay? pickedStartTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startDate ?? DateTime.now()),
        helpText: 'Виберіть час початку оренди',
      );
      
      if (pickedStartTime != null) {
        // Зберігаємо повну дату і час початку
        final newStartDate = DateTime(
          pickedStartDate.year,
          pickedStartDate.month,
          pickedStartDate.day,
          pickedStartTime.hour,
          pickedStartTime.minute,
        );
        
        // Тепер показуємо picker для дати закінчення оренди
        final DateTime? pickedEndDate = await showDatePicker(
          context: context,
          initialDate: endDate ?? pickedStartDate.add(const Duration(days: 7)),
          firstDate: pickedStartDate,
          lastDate: pickedStartDate.add(const Duration(days: 365)),
          helpText: 'Виберіть дату закінчення оренди',
        );
        
        if (pickedEndDate != null) {
          // Якщо вибрали дату закінчення, показуємо picker для часу закінчення
          final TimeOfDay? pickedEndTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(endDate ?? DateTime.now().add(const Duration(days: 7))),
            helpText: 'Виберіть час закінчення оренди',
          );
          
          if (pickedEndTime != null) {
            // Зберігаємо повну дату і час закінчення
            final newEndDate = DateTime(
              pickedEndDate.year,
              pickedEndDate.month,
              pickedEndDate.day,
              pickedEndTime.hour,
              pickedEndTime.minute,
            );
            
            // Оновлюємо стан з новими датами
            setState(() {
              startDate = newStartDate;
              endDate = newEndDate;
            });
          }
        }
      }
    }
  }

  void _bookCar() async {
    // Перевіряємо, чи вибрано дати
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Будь ласка, виберіть період оренди'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Перевіряємо, чи дата кінця пізніше дати початку
    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дата закінчення має бути пізніше дати початку'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final carService = CarService();

    setState(() {
      _isLoading = true;
    });

    try {
      // Використовуємо новий метод з датами для бронювання
      await carService.bookCarWithDates(widget.car.id, startDate!, endDate!);
      
      setState(() {
        _isLoading = false;
        _isBooked = true;
      });

      // Show confirmation dialog
      _showBookingConfirmationDialog();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Показуємо повідомлення про помилку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка при бронюванні: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _cancelBooking() async {
    final carService = CarService();

    setState(() {
      _isLoading = true;
    });

    try {
      // Використовуємо новий метод rejectBooking з DELETE /bookings/{id} ендпоінтом
      // Для демонстрації припускаємо, що ID бронювання це ID автомобіля (в реальному додатку це мав би бути ID бронювання)
      String bookingId = widget.car.id;
      print('DEBUG: Відхиляємо бронювання з ID: $bookingId');
      
      await carService.rejectBooking(bookingId);
      
      // Також оновлюємо локальний стан carService
      carService.unbookCar(widget.car.id);
      
      // Важливо: очищуємо кеш для оновлення списків автомобілів
      carService.clearCache();
      
      setState(() {
        _isLoading = false;
        _isBooked = false;
      });
      
      // Показуємо повідомлення про успішне відхилення
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бронювання успішно відхилено'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Повертаємось на попередній екран із індикатором про необхідність оновлення
      Navigator.of(context).pop({
        'refreshMyCars': true,   // Вказуємо, що потрібно оновити вкладку "Мої авто"
        'refreshSearchCars': true  // Вказуємо, що потрібно оновити вкладку "Пошук авто"
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Показуємо повідомлення про помилку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка при відхиленні бронювання: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showBookingConfirmationDialog() {
    String confirmationText = 'Автомобіль заброньовано за Вами.\nНіхто інший його зараз забронювати не зможе.';
    
    // Додаємо інформацію про автопарк тільки якщо всі автопарки доступні
    if (_fleetMode == FleetMode.all) {
      confirmationText += '\nЧекаємо підтвердження від ${widget.car.carPark}.';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Автомобіль заброньовано'),
        content: Text(
          confirmationText,
          style: const TextStyle(
            fontSize: 16.0, // Larger font size
            color: Color(0xFF333333), // Darker text color
            height: 1.5, // Increased line height for better readability
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog

              // Navigate back to home screen and switch to "My Cars" tab (index 0)
              Navigator.of(context).pop({'switchToMyCars': true});
            },
            child: const Text('Добре'),
          ),
        ],
      ),
    );
  }
}
