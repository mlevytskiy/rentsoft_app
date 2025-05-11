import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/api_config_service.dart';
import '../../../core/services/scenario_service.dart';
import '../../../features/auth/screens/auth_screen.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
import 'car_detail_screen.dart';


// Factory method to create unique keys for CarSearchScreen
GlobalKey<CarSearchScreenState> createCarSearchScreenKey() {
  return GlobalKey<CarSearchScreenState>();
}

class CarSearchScreen extends StatefulWidget {
  const CarSearchScreen({super.key});

  @override
  State<CarSearchScreen> createState() => CarSearchScreenState();
}

// Make class public to access via key
class CarSearchScreenState extends State<CarSearchScreen> {
  final _searchController = TextEditingController();
  final _carService = CarService();
  final _scenarioService = getIt<ScenarioService>();
  final _apiConfigService = getIt<ApiConfigService>();
  final _secureStorage = const FlutterSecureStorage();
  List<Car> _cars = [];
  bool _isLoading = true;
  String? _error;
  bool _isAuthorized = false;
  FleetMode _fleetMode = FleetMode.all;

  // Filter states
  RangeValues _priceRange = const RangeValues(1500, 4000);
  String? _selectedBrand;
  int? _selectedSeats;
  String? _selectedFuelType;
  String? _selectedCarPark;

  final List<String> _brands = [
    'Audi',
    'BMW',
    'Chevrolet',
    'Ford',
    'Honda',
    'Hyundai',
    'Jeep',
    'Kia',
    'Land Rover',
    'Lexus',
    'Mazda',
    'Mercedes-Benz',
    'Nissan',
    'Porsche',
    'Renault',
    'Skoda',
    'Tesla',
    'Toyota',
    'Volkswagen',
    'Volvo',
  ];

  final List<String> _fuelTypes = [
    'Бензин',
    'Дизель',
    'Гібрид',
    'Електро',
  ];

  final List<String> _carParks = [
    'Автопарк 1',
    'Автопарк 2',
    'Автопарк 3',
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _loadFleetMode();
  }
  
  // Публічний метод для перезавантаження даних екрану
  void reloadCars() {
    _checkAuthStatus();
  }
  
  // Перевіряємо статус авторизації користувача
  Future<void> _checkAuthStatus() async {
    final token = await _secureStorage.read(key: 'access_token');
    setState(() {
      _isAuthorized = token != null && token.isNotEmpty;
    });
    
    if (_isAuthorized) {
      _loadCars();
    } else {
      // якщо не авторизований, відображаємо порожній список
      setState(() {
        _isLoading = false;
        _error = null;
      });
    }
  }

  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Перевіряємо токен перед запитом
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        print('DEBUG: CarSearchScreen - токен відсутній');
        setState(() {
          _isLoading = false;
          _isAuthorized = false;
        });
        return;
      }
      
      // Get all available cars
      final availableCars = await _carService.getAvailableCars();
      
      // Apply filters to the list
      final filteredCars = availableCars.where((car) {
        // Price filter
        if (car.pricePerWeek < _priceRange.start.toInt() || car.pricePerWeek > _priceRange.end.toInt()) {
          return false;
        }

        // Brand filter
        if (_selectedBrand != null && _selectedBrand!.isNotEmpty && car.brand != _selectedBrand) {
          return false;
        }

        // Seats filter
        if (_selectedSeats != null && car.seats < _selectedSeats!) {
          return false;
        }

        // Fuel type filter
        if (_selectedFuelType != null && _selectedFuelType!.isNotEmpty && car.fuelType != _selectedFuelType) {
          return false;
        }

        // Car park filter
        if (_selectedCarPark != null && _selectedCarPark!.isNotEmpty && car.carPark != _selectedCarPark) {
          return false;
        }

        // Search text filter
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          return car.fullName.toLowerCase().contains(query);
        }

        return true;
      }).toList();

      setState(() {
        _cars = filteredCars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Завантажуємо поточний режим відображення автопарків
  Future<void> _loadFleetMode() async {
    final fleetMode = await _scenarioService.getFleetMode();
    final isOfflineMode = await _apiConfigService.isOfflineMode();
    
    setState(() {
      _fleetMode = fleetMode;
      
      // Якщо режим одного автопарку, встановлюємо фільтр автоматично
      if (_fleetMode == FleetMode.single) {
        _selectedCarPark = 'Автопарк 1';
      }
    });
    
    // Якщо офлайн режим, не потрібна авторизація
    if (isOfflineMode) {
      setState(() {
        _isAuthorized = true; // в офлайн режимі можемо працювати без авторизації
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: _isAuthorized 
          ? Column(
              children: [
                _buildSearchBar(),
                _buildFilters(),
                Expanded(child: _buildCarList()),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.no_accounts, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Для перегляду автомобілів потрібно увійти',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Будь ласка, авторизуйтесь для доступу до пошуку автомобілів',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      ).then((_) => _checkAuthStatus());
                    },
                    child: const Text('Увійти'),
                  ),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show rental period dialog
          _showRentalPeriodDialog(context);
        },
        label: const Text('Період оренди'),
        icon: const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 6.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Пошук авто для твоєї подорожі',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Visibility(visible: false, child: Icon(Icons.history)),
            onPressed: () {
              // History functionality would go here
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFE8E7EF),
        ),
        onChanged: (value) {
          _loadCars();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Ціна', () => _showPriceFilterDialog()),
          _buildFilterChip('Місця', () => _showSeatsFilterDialog()),
          _buildFilterChip('Марка', () => _showBrandFilterDialog()),
          _buildFilterChip('Паливо', () => _showFuelTypeFilterDialog()),
          // Показуємо фільтр автопарків тільки в режимі "всі автопарки"
          if (_fleetMode == FleetMode.all)
            _buildFilterChip('Автопарк', () => _showCarParkFilterDialog()),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        labelPadding: const EdgeInsets.only(right: 2.0),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
        onSelected: (bool selected) {
          if (selected) {
            onTap();
          }
        },
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  void _showPriceFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ціна за тиждень'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RangeSlider(
                  values: _priceRange,
                  min: 1500,
                  max: 4000,
                  divisions: 25,
                  labels: RangeLabels(
                    '${_priceRange.start.round()} ₴',
                    '${_priceRange.end.round()} ₴',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_priceRange.start.round()} ₴'),
                    Text('${_priceRange.end.round()} ₴'),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _loadCars();
            },
            child: const Text('Застосувати'),
          ),
        ],
      ),
    );
  }

  void _showSeatsFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Кількість місць'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Будь-яка'),
              leading: Radio<int?>(
                value: null,
                groupValue: _selectedSeats,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedSeats = value;
                  });
                  _loadCars();
                },
              ),
            ),
            for (var i = 4; i <= 7; i++)
              ListTile(
                title: Text('$i+'),
                leading: Radio<int?>(
                  value: i,
                  groupValue: _selectedSeats,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      _selectedSeats = value;
                    });
                    _loadCars();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBrandFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Марка автомобіля'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Будь-яка'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _selectedBrand,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      _selectedBrand = value;
                    });
                    _loadCars();
                  },
                ),
              ),
              for (var brand in _brands)
                ListTile(
                  title: Text(brand),
                  leading: Radio<String?>(
                    value: brand,
                    groupValue: _selectedBrand,
                    onChanged: (value) {
                      Navigator.pop(context);
                      setState(() {
                        _selectedBrand = value;
                      });
                      _loadCars();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFuelTypeFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тип палива'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Будь-який'),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedFuelType,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedFuelType = value;
                  });
                  _loadCars();
                },
              ),
            ),
            for (var fuelType in _fuelTypes)
              ListTile(
                title: Text(fuelType),
                leading: Radio<String?>(
                  value: fuelType,
                  groupValue: _selectedFuelType,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      _selectedFuelType = value;
                    });
                    _loadCars();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCarParkFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Автопарк'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Будь-який'),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedCarPark,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedCarPark = value;
                  });
                  _loadCars();
                },
              ),
            ),
            for (var carPark in _carParks)
              ListTile(
                title: Text(carPark),
                leading: Radio<String?>(
                  value: carPark,
                  groupValue: _selectedCarPark,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      _selectedCarPark = value;
                    });
                    _loadCars();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRentalPeriodDialog(BuildContext context) {
    final now = DateTime.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Оберіть період оренди',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _datePickerField(
                    'Початок оренди',
                    DateTime(now.year, now.month, now.day),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _datePickerField(
                    'Кінець оренди',
                    DateTime(now.year, now.month, now.day + 7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Apply rental period filter logic would go here
                },
                child: const Text('Застосувати'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePickerField(String label, DateTime initialDate) {
    return TextFormField(
      readOnly: true,
      initialValue: '${initialDate.day}/${initialDate.month}/${initialDate.year}',
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        // ignore: unused_local_variable
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        // Date selection handling will be implemented later
      },
    );
  }

  Widget _buildCarList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Помилка завантаження даних',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCars,
              child: const Text('Спробувати знову'),
            ),
          ],
        ),
      );
    }
    
    if (_cars.isEmpty) {
      return const Center(
        child: Text(
          'Немає доступних автомобілів за вашими фільтрами',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _cars.length,
      itemBuilder: (context, index) {
        return _buildCarCard(_cars[index]);
      },
    );
  }

  Widget _buildCarCard(Car car) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFE2E2E9),
      child: InkWell(
        onTap: () async {
          // Navigation to details screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => CarDetailScreen(car: car),
            ),
          );

          // Check if we need to switch to My Cars tab
          if (result != null && result is Map && result['switchToMyCars'] == true) {
            // Notify parent (HomeScreen) to switch to My Cars tab
            if (context.mounted) {
              // Find the nearest ScaffoldMessenger and post a notification
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Перехід до ваших орендованих авто...'),
                  duration: Duration(seconds: 1),
                ),
              );

              // Navigate back to home screen
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop({'switchToMyCars': true});
              }
            }
          }

          // Refresh car list after returning from details
          _loadCars();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  car.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Показуємо назву автопарку тільки в режимі "всі автопарки"
                if (_fleetMode == FleetMode.all)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        car.carPark,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          car.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₴${car.pricePerWeek}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.local_gas_station, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(car.fuelType, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(width: 16),
                      Icon(Icons.airline_seat_recline_normal, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${car.seats} місць', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
