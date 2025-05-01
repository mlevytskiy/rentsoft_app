import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/car_id_mapper.dart';
import '../../../utils/seed_data_button.dart';
import '../../booking/models/booking_model.dart';
import '../../booking/repositories/booking_repository.dart';
import '../models/car_model.dart';
import '../repositories/car_repository.dart';
import '../services/car_service.dart';
import 'car_detail_screen.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  final _carService = CarService();
  final _carRepository = CarRepository();
  final _bookingRepository = BookingRepository();
  final _carIdMapper = CarIdMapper();

  List<Car> _bookedCars = [];
  List<Booking> _bookings = [];
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initUserId();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> initUserId() async {
    // In a real app, this would come from authentication
    // For now, we'll generate and store a user ID in shared preferences
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('user_id', userId);
    }

    // Set the user ID and immediately load cars
    if (mounted) {
      setState(() {
        _userId = userId;
      });

      // Immediately load booked cars
      _loadBookedCars();
    }
  }

  void _loadBookedCars() {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    if (_userId == null) return;

    print('Loading booked cars for user: $_userId');

    // Initialize the car ID mapper before loading cars
    _carIdMapper.initialize().then((_) {
      // First, load all cars from Firestore so we have them cached
      _carRepository.getAllCars().then((allCars) {
        print('Preloaded ${allCars.length} cars from Firestore');
        // Create a map of all cars by ID for faster lookup
        final Map<String, Car> carsById = {for (var car in allCars) car.id: car};
        print('Cars by ID: ${carsById.keys.toList()}');
        
        // Then, listen to active bookings for this user
        _bookingRepository.getUserActiveBookingsStream(_userId!).listen((bookings) async {
          if (!mounted) return;

          // Filter out cancelled and rejected bookings client-side
          final activeBookings = bookings.where((booking) => 
            booking.status != BookingStatus.cancelled && 
            booking.status != BookingStatus.rejected
          ).toList();

          print('Received ${bookings.length} bookings from Firestore');
          print('Active bookings: ${activeBookings.length}');

          if (activeBookings.isEmpty) {
            setState(() {
              _bookings = [];
              _bookedCars = [];
              _isLoading = false;
            });
            return;
          }

          // Get car IDs from bookings
          final carIds = activeBookings.map((booking) => booking.carId).toList();
          print('Car IDs to fetch: $carIds');

          try {
            // Look up cars from both the local cache and from Firestore
            List<Car> cars = [];
            List<String> notFoundCarIds = [];
            
            // First try to get cars from our local cache of all cars
            for (final carId in carIds) {
              if (carsById.containsKey(carId)) {
                cars.add(carsById[carId]!);
              } else {
                notFoundCarIds.add(carId);
              }
            }
            
            // If some cars were not found in the local cache, try to fetch them from Firestore
            if (notFoundCarIds.isNotEmpty) {
              print('Fetching cars with IDs not in cache: $notFoundCarIds');
              final additionalCars = await _carRepository.getCarsByIds(notFoundCarIds);
              cars.addAll(additionalCars);
              print('Retrieved ${additionalCars.length} additional cars from Firestore');
            }
            
            print('Total cars found: ${cars.length} out of ${carIds.length} requested');

            // Make a placeholder car for any cars that weren't found
            final Map<String, Car> foundCarsById = {for (var car in cars) car.id: car};
            
            // Create a map of bookings by car ID for faster lookup
            final List<Car> displayCars = [];
            final List<Booking> displayBookings = [];

            // For each active booking, add the corresponding car (or placeholder) to the display lists
            for (final booking in activeBookings) {
              // Debug the booking and its carId to see what we're dealing with
              print('Processing booking: ${booking.id} with carId: [${booking.carId}], type: ${booking.carId.runtimeType}');
              
              // Check if this booking carId might be numeric (like "13") when our Firestore IDs are alphanumeric
              Car? car;
              
              // First try direct lookup
              car = foundCarsById[booking.carId];
              
              // If that fails, try using the mapper
              if (car == null) {
                // Try to map the simple ID to a Firestore ID
                final mappedFirestoreId = _carIdMapper.getFirestoreId(booking.carId);
                if (mappedFirestoreId != null) {
                  car = foundCarsById[mappedFirestoreId];
                  print('Using mapped Firestore ID: $mappedFirestoreId for simple ID: ${booking.carId}');
                }
              }
              
              // If that still fails, try looking through all car IDs to find one that might match
              if (car == null && booking.carId.length <= 2) {
                // This might be a numeric ID
                print('Trying to find car with numeric ID: ${booking.carId}');
                // Look through all cars to try to find a match
                for (final carEntry in foundCarsById.entries) {
                  if (carEntry.key.contains(booking.carId)) {
                    car = carEntry.value;
                    print('Found potential match: ${carEntry.key} for carId: ${booking.carId}');
                    break;
                  }
                }
              }
              
              // Additional logging to debug car lookup
              print('Matching car found? ${car != null}');
              
              if (car != null) {
                // We found the car, use it
                displayCars.add(car);
                displayBookings.add(booking);
                // Update local state with CarService (for compatibility with existing code)
                _carService.bookCar(car.id);
              } else {
                // Create a placeholder car for bookings where the car wasn't found
                final placeholderCar = Car(
                  id: booking.carId,
                  brand: 'Unknown',
                  model: 'Car',
                  year: 2023,
                  imageUrl: 'https://www.motortrend.com/uploads/sites/5/2020/03/2020-Honda-Civic-sedan-touring.jpg',
                  pricePerWeek: 0,
                  fuelType: 'Unknown',
                  seats: 4,
                  carPark: 'Unknown',
                );
                
                displayCars.add(placeholderCar);
                displayBookings.add(booking);
                print('Created placeholder for missing car ID: ${booking.carId}');
              }
            }

            if (mounted) {
              setState(() {
                _bookedCars = displayCars;
                _bookings = displayBookings;
                _isLoading = false;
              });
              print('Updated UI with ${displayCars.length} cars and ${displayBookings.length} bookings');
            }
          } catch (e) {
            print('Error fetching cars: $e');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        }, onError: (error) {
          print('Error in booking stream: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Мої заброньовані автомобілі',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _bookedCars.isEmpty
                    ? const Center(
                        child: Text(
                          'У вас немає заброньованих автомобілів',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _bookedCars.length,
                        itemBuilder: (context, index) {
                          final car = _bookedCars[index];
                          final booking = _bookings[index];
                          return _buildBookedCarCard(car, booking);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: const SeedDataButton(),
    );
  }

  Widget _buildBookedCarCard(Car car, Booking booking) {
    // Determine status color and text
    Color statusColor;
    String statusText;

    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Очікує підтвердження';
        break;
      case BookingStatus.approved:
        statusColor = Colors.green;
        statusText = 'Підтверджено';
        break;
      case BookingStatus.rejected:
        statusColor = Colors.red;
        statusText = 'Відхилено';
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Скасовано';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarDetailScreen(car: car),
            ),
          );
          // Refresh list when returning from detail screen
          _loadBookedCars();
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
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
                      Icon(Icons.business, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(car.carPark, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(width: 16),
                      Icon(Icons.local_gas_station, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(car.fuelType, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(booking.startDate)} - ${_formatDate(booking.endDate)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  if (booking.adminNote != null && booking.adminNote!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Коментар адміністратора:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.adminNote!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
