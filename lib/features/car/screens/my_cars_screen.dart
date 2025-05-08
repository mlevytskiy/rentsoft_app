import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
import 'car_detail_screen.dart';

// Замість глобального ключа використовуємо фабричний метод для створення унікальних ключів
GlobalKey<MyCarsScreenState> createMyCarsScreenKey() {
  return GlobalKey<MyCarsScreenState>();
}

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => MyCarsScreenState();
}

// Змінюємо видимість класу з приватного на публічний
class MyCarsScreenState extends State<MyCarsScreen> {
  final _carService = CarService();
  late Future<List<Car>> _bookedCarsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookedCars();
  }

  // Публічний метод для перезавантаження даних екрану
  void reloadBookedCars() {
    _loadBookedCars();
  }

  void _loadBookedCars() {
    setState(() {
      _bookedCarsFuture = _carService.getBookedCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Мої заброньовані автомобілі',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Car>>(
                future: _bookedCarsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Помилка завантаження: ${snapshot.error}',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'У вас немає заброньованих автомобілів',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  final bookedCars = snapshot.data!;
                  return ListView.builder(
                    itemCount: bookedCars.length,
                    itemBuilder: (context, index) {
                      return _buildBookedCarCard(bookedCars[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookedCarCard(Car car) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () async {
          // Використовуємо Navigator.push з новим контекстом навігації (rootNavigator: true)
          // Це дозволяє обійти нижні таби
          await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => CarDetailScreen(car: car),
              fullscreenDialog: true,
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
                      color: Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Заброньовано',
                      style: TextStyle(color: Colors.white, fontSize: 12),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
