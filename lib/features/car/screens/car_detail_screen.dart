import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';
import '../services/car_service.dart'; // Import CarService
import '../../booking/repositories/booking_repository.dart';

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
  String? _userId;
  
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

  // Booking repository
  final BookingRepository _bookingRepository = BookingRepository();
  String? _currentBookingId;

  @override
  void initState() {
    super.initState();
    
    // Initialize default dates
    startDate = DateTime.now();
    endDate = DateTime.now().add(const Duration(days: 7));
    
    _initUserId().then((_) {
      _checkIfCarIsBooked();
    });
  }
  
  Future<void> _initUserId() async {
    // In a real app, this would come from authentication
    // For now, we'll generate and store a user ID in shared preferences
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    
    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('user_id', userId);
    }
    
    setState(() {
      _userId = userId;
    });
  }
  
  Future<void> _checkIfCarIsBooked() async {
    if (_userId == null) return;
    
    // Check if this car is booked by the current user
    final bookings = await _bookingRepository.getUserActiveBookingsStream(_userId!).first;
    final carBookings = bookings.where((booking) => booking.carId == widget.car.id).toList();
    
    if (carBookings.isNotEmpty) {
      final booking = carBookings.first;
      final carService = CarService();
      carService.bookCar(widget.car.id);
      
      setState(() {
        _isBooked = true;
        _currentBookingId = booking.id;
        startDate = booking.startDate;
        endDate = booking.endDate;
      });
    }
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
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Період оренди',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _selectDateRange(context),
              child: const Text(
                'Змінити',
                style: TextStyle(
                  color: Color(0xFF3F5185),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Початок',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      startDate != null ? dateFormat.format(startDate!) : 'Не вибрано',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 24,
                width: 1,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Кінець',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      endDate != null ? dateFormat.format(endDate!) : 'Не вибрано',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3F5185),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
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

  void _bookCar() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Будь ласка, виберіть період оренди')),
      );
      return;
    }
    
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Помилка: не знайдено ID користувача')),
      );
      return;
    }
    
    final carService = CarService();
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if car is available for the selected date range
      final isAvailable = await _bookingRepository.isCarAvailableForBooking(
        widget.car.id,
        startDate!,
        endDate!,
      );
      
      if (!isAvailable) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('На жаль, цей автомобіль уже заброньований на вибрані дати'),
          ),
        );
        return;
      }
      
      // Create booking in Firestore
      final bookingId = await _bookingRepository.createBooking(
        carId: widget.car.id,
        userId: _userId!,
        startDate: startDate!,
        endDate: endDate!,
      );
      
      // Update local state
      carService.bookCar(widget.car.id);
      
      setState(() {
        _isLoading = false;
        _isBooked = true;
        _currentBookingId = bookingId;
      });
      
      // Show confirmation dialog
      _showBookingConfirmationDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: ${e.toString()}')),
      );
    }
  }

  void _cancelBooking() async {
    if (_currentBookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неможливо скасувати бронювання')),
      );
      return;
    }
    
    final carService = CarService();
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Cancel booking in Firestore
      await _bookingRepository.cancelBooking(_currentBookingId!);
      
      // Update local state
      carService.unbookCar(widget.car.id);
      
      setState(() {
        _isLoading = false;
        _isBooked = false;
        _currentBookingId = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: ${e.toString()}')),
      );
    }
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
