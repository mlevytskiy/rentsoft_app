import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/booking/models/booking_model.dart';

class SeedData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add sample cars to Firestore
  Future<List<String>> seedCars() async {
    final List<String> carIds = [];

    // Sample car data
    final List<Map<String, dynamic>> carsData = [
      {
        'make': 'Toyota',
        'model': 'Camry',
        'year': 2023,
        'color': 'White',
        'carPark': 'RentSoft Kyiv',
        'mileage': 5000,
        'fuelType': 'Hybrid',
        'transmission': 'Automatic',
        'pricePerDay': 45,
        'pricePerWeek': 280,
        'isAvailable': true,
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/a/ac/2018_Toyota_Camry_%28ASV70R%29_Ascent_sedan_%282018-08-27%29_01.jpg',
      },
      {
        'make': 'Honda',
        'model': 'Civic',
        'year': 2022,
        'color': 'Blue',
        'carPark': 'RentSoft Lviv',
        'mileage': 8000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'pricePerDay': 40,
        'pricePerWeek': 240,
        'isAvailable': true,
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/6/6d/2017_Honda_Civic_SR_VTEC_1.0_Front.jpg',
      },
      {
        'make': 'Volkswagen',
        'model': 'Golf',
        'year': 2021,
        'color': 'Black',
        'carPark': 'RentSoft Kyiv',
        'mileage': 12000,
        'fuelType': 'Diesel',
        'transmission': 'Manual',
        'pricePerDay': 38,
        'pricePerWeek': 230,
        'isAvailable': true,
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/2/25/2019_Volkswagen_Golf_SE_Nav_1.6.jpg',
      },
    ];

    // Add each car to Firestore
    for (final carData in carsData) {
      try {
        final docRef = await _firestore.collection('cars').add(carData);
        carIds.add(docRef.id);
        print('Added car to Firestore: ${carData['make']} ${carData['model']} with ID: ${docRef.id}');
      } catch (e) {
        print('Error adding car: $e');
      }
    }

    return carIds;
  }

  // Add sample bookings to Firestore
  Future<void> seedBookings(List<String> carIds) async {
    if (carIds.isEmpty) {
      print('No car IDs provided, cannot seed bookings');
      return;
    }

    // Get current user ID
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      print('No user ID found, cannot seed bookings');
      return;
    }

    // Sample booking data
    final now = DateTime.now();
    final List<Map<String, dynamic>> bookingsData = [
      {
        'carId': carIds[0],
        'userId': userId,
        'startDate': Timestamp.fromDate(now.add(const Duration(days: 1))),
        'endDate': Timestamp.fromDate(now.add(const Duration(days: 5))),
        'status': BookingStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'adminNote': null,
      },
      {
        'carId': carIds.length > 1 ? carIds[1] : carIds[0],
        'userId': userId,
        'startDate': Timestamp.fromDate(now.add(const Duration(days: 10))),
        'endDate': Timestamp.fromDate(now.add(const Duration(days: 15))),
        'status': BookingStatus.approved.name,
        'createdAt': FieldValue.serverTimestamp(),
        'adminNote': 'All set for your booking. Please pick up the car at 9 AM.',
      },
    ];

    // Add each booking to Firestore
    for (final bookingData in bookingsData) {
      try {
        final docRef = await _firestore.collection('bookings').add(bookingData);
        print('Added booking to Firestore with ID: ${docRef.id}');
      } catch (e) {
        print('Error adding booking: $e');
      }
    }
  }

  // Seed both cars and bookings
  Future<void> seedDataForTesting() async {
    try {
      print('Starting to seed test data...');
      final carIds = await seedCars();
      if (carIds.isNotEmpty) {
        await seedBookings(carIds);
      }
      print('Completed seeding test data');
    } catch (e) {
      print('Error seeding test data: $e');
    }
  }
}
