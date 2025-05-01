import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
import 'car_detail_screen.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  final _carService = CarService();
  late List<Car> _bookedCars;

  @override
  void initState() {
    super.initState();
    _loadBookedCars();
  }

  void _loadBookedCars() {
    setState(() {
      _bookedCars = _carService.getBookedCars();
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
            child: _bookedCars.isEmpty
                ? const Center(
                    child: Text(
                      'У вас немає заброньованих автомобілів',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _bookedCars.length,
                    itemBuilder: (context, index) {
                      return _buildBookedCarCard(_bookedCars[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookedCarCard(Car car) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
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
