import 'package:flutter/material.dart';
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
  
  // Selected rental options
  String selectedRentalType = 'Тижнева'; // Default rental type
  String selectedPaymentType = 'Щотижнево'; // Default payment type
  bool isFavorite = false;
  bool _showCarParkContacts = false; // Flag to toggle contact info visibility
  bool _isBooked = false; // Booking status
  bool _isLoading = false; // Loading state

  // Car park contact information
  final Map<String, Map<String, String>> _carParkContacts = {
    'Автопарк 1': {
      'address': 'м. Львів, вул. Чорновола 36/5',
      'phone': '+380 (67) 123-45-67'
    },
    'Автопарк 2': {
      'address': 'м. Київ, вул. Хрещатик 14',
      'phone': '+380 (50) 987-65-43'
    },
    'Автопарк 3': {
      'address': 'м. Одеса, вул. Дерибасівська 22',
      'phone': '+380 (63) 555-77-88'
    },
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildCarImages(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarInfoSection(),
                    const Divider(height: 32),
                    _buildRentalTypeSection(),
                    const Divider(height: 32),
                    _buildPaymentSection(),
                    const Divider(height: 32),
                    _buildRentalPeriodSection(),
                    const SizedBox(height: 24),
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

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      title: Text(widget.car.fullName),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: () {
            setState(() {
              isFavorite = !isFavorite;
            });
          },
        ),
      ],
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
          height: 220,
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
                child: Image.network(
                  images[1],
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _showCarParkContacts = !_showCarParkContacts;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        widget.car.carPark,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showCarParkContacts ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                if (carParkInfo != null && _showCarParkContacts) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Контакти:',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    carParkInfo['address']!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    carParkInfo['phone']!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
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
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
        borderRadius: BorderRadius.circular(30),
      ),
      avatar: Icon(icon, size: 18),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 14),
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSelectionChip('Тижнева', 'Тижнева'),
            const SizedBox(width: 8),
            _buildSelectionChip('Подобова', 'Подобова'),
            const SizedBox(width: 8),
            _buildSelectionChip('Погодинна', 'Погодинна'),
          ],
        ),
      ],
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
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSelectionChip('Щотижнево', 'Щотижнево', hasIcon: true, icon: Icons.update),
            const SizedBox(width: 8),
            _buildSelectionChip('Застава', 'Застава', hasIcon: true, icon: Icons.shield),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionChip(String label, String value, {bool hasIcon = false, IconData? icon}) {
    final isSelected = value == selectedRentalType || value == selectedPaymentType;
    
    return FilterChip(
      selected: isSelected,
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      avatar: hasIcon && icon != null ? Icon(icon, size: 18) : null,
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 14),
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.arrow_outward, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  _formatDate(startDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            TextButton(
              onPressed: _showDateTimePicker,
              child: const Text('Змінити'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.arrow_downward, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              _formatDate(endDate),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceAndRentButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  const WidgetSpan(
                    child: Text('₴', style: TextStyle(fontSize: 20)),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  TextSpan(
                    text: ' ${widget.car.pricePerWeek}',
                    style: const TextStyle(
                      fontSize: 24,
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
                fontSize: 14,
              ),
            ),
          ],
        ),
        _isLoading
            ? const SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(),
              )
            : ElevatedButton(
                onPressed: _isBooked ? _cancelBooking : _bookCar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBooked ? Colors.red.shade700 : const Color(0xFF3F5185),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_isBooked ? 'Відмінити бронювання' : 'Орендувати'),
              ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString();
    final months = [
      'Січня', 'Лютого', 'Березня', 'Квітня', 'Травня', 'Червня',
      'Липня', 'Серпня', 'Вересня', 'Жовтня', 'Листопада', 'Грудня'
    ];
    final month = months[date.month - 1];
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$day $month, $time';
  }

  void _showDateTimePicker() {
    // Show date picker, followed by time picker
    // This is a placeholder for actual implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Період оренди'),
        content: const Text('Тут буде відображено вибір дат і часу'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _bookCar() {
    final carService = CarService();
    
    setState(() {
      _isLoading = true;
    });

    // Simulate network request
    Future.delayed(const Duration(seconds: 1), () {
      carService.bookCar(widget.car.id);
      
      setState(() {
        _isLoading = false;
        _isBooked = true;
      });
      
      // Show confirmation dialog
      _showBookingConfirmationDialog();
    });
  }
  
  void _cancelBooking() {
    final carService = CarService();
    
    setState(() {
      _isLoading = true;
    });

    // Simulate network request
    Future.delayed(const Duration(seconds: 1), () {
      carService.unbookCar(widget.car.id);
      
      setState(() {
        _isLoading = false;
        _isBooked = false;
      });
    });
  }
  
  void _showBookingConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Автомобіль заброньовано'),
        content: Text(
          'Автомобіль заброньовано за вами, ніхто інший його зараз забронювати не зможе. '
          'Чекаємо підтвердження від ${widget.car.carPark}.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Добре'),
          ),
        ],
      ),
    );
  }
}
