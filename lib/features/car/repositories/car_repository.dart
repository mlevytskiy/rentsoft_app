import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_service.dart';
import '../../../utils/car_id_mapper.dart';
import '../models/car_model.dart';

class CarRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final CarIdMapper _carIdMapper = CarIdMapper();
  CollectionReference get _carsCollection => _firebaseService.firestore.collection('cars');

  // Get all cars
  Future<List<Car>> getAllCars() async {
    try {
      final snapshot = await _carsCollection.get();
      List<Car> cars = [];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;

          // Handle different field naming and null values
          final brand = data['brand'] ?? data['make'] ?? 'Unknown';
          final model = data['model'] ?? 'Unknown';
          final year = data['year'] is int ? data['year'] : 2023;
          final imageUrl = data['imageUrl'] ?? '';
          final pricePerWeek = data['pricePerWeek'] is int ? data['pricePerWeek'] : 0;
          final fuelType = data['fuelType'] ?? 'Unknown';
          final seats = data['seats'] is int ? data['seats'] : 5;
          final carPark = data['carPark'] ?? 'Unknown';

          cars.add(Car(
            id: doc.id,
            brand: brand,
            model: model,
            year: year,
            imageUrl: imageUrl,
            pricePerWeek: pricePerWeek,
            fuelType: fuelType,
            seats: seats,
            carPark: carPark,
          ));
        } catch (e) {
          print('Error creating Car from doc ${doc.id}: $e');
          // Continue to the next document
        }
      }

      return cars;
    } catch (e) {
      print('Error getting all cars: $e');
      return [];
    }
  }

  // Get cars by IDs
  Future<List<Car>> getCarsByIds(List<String> carIds) async {
    if (carIds.isEmpty) return [];

    // Initialize the car ID mapper if it hasn't been already
    await _carIdMapper.initialize();

    // Filter out invalid IDs (like null or empty strings)
    final validCarIds = carIds.where((id) => id.isNotEmpty).toList();
    if (validCarIds.isEmpty) return [];

    // Convert simple IDs to Firestore document IDs where needed
    List<String> firestoreCarIds = [];
    for (final simpleId in validCarIds) {
      // Try to get the Firestore ID for this simple ID
      final firestoreId = _carIdMapper.getFirestoreId(simpleId);
      if (firestoreId != null) {
        firestoreCarIds.add(firestoreId);
        print('Mapped simple ID $simpleId to Firestore ID $firestoreId');
      } else {
        // If we couldn't map it, still try the original ID
        firestoreCarIds.add(simpleId);
        print('No mapping found for ID $simpleId, using as-is');
      }
    }

    // Firestore can only query 10 items at a time in a whereIn clause
    List<Car> results = [];
    for (var i = 0; i < firestoreCarIds.length; i += 10) {
      final endIndex = (i + 10 < firestoreCarIds.length) ? i + 10 : firestoreCarIds.length;
      final batch = firestoreCarIds.sublist(i, endIndex);

      try {
        final snapshot = await _carsCollection.where(FieldPath.documentId, whereIn: batch).get();

        for (final doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;

            // Handle different field naming (make vs brand)
            final brand = data['brand'] ?? data['make'] ?? 'Unknown';
            final model = data['model'] ?? 'Unknown';
            final year = data['year'] is int ? data['year'] : 2023;
            final imageUrl = data['imageUrl'] ?? '';
            final pricePerWeek = data['pricePerWeek'] is int ? data['pricePerWeek'] : 0;
            final fuelType = data['fuelType'] ?? 'Unknown';
            final seats = data['seats'] is int ? data['seats'] : 5;
            final carPark = data['carPark'] ?? 'Unknown';

            results.add(Car(
              id: doc.id,
              brand: brand,
              model: model,
              year: year,
              imageUrl: imageUrl,
              pricePerWeek: pricePerWeek,
              fuelType: fuelType,
              seats: seats,
              carPark: carPark,
            ));
          } catch (e) {
            print('Error creating Car from doc ${doc.id}: $e');
            // Continue to the next document
          }
        }
      } catch (e) {
        print('Error querying batch of cars: $e');
        // Continue to the next batch
      }
    }

    return results;
  }

  // Get car by ID
  Future<Car?> getCarById(String carId) async {
    try {
      final doc = await _carsCollection.doc(carId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;

      // Handle different field naming and null values
      final brand = data['brand'] ?? data['make'] ?? 'Unknown';
      final model = data['model'] ?? 'Unknown';
      final year = data['year'] is int ? data['year'] : 2023;
      final imageUrl = data['imageUrl'] ?? '';
      final pricePerWeek = data['pricePerWeek'] is int ? data['pricePerWeek'] : 0;
      final fuelType = data['fuelType'] ?? 'Unknown';
      final seats = data['seats'] is int ? data['seats'] : 5;
      final carPark = data['carPark'] ?? 'Unknown';

      return Car(
        id: doc.id,
        brand: brand,
        model: model,
        year: year,
        imageUrl: imageUrl,
        pricePerWeek: pricePerWeek,
        fuelType: fuelType,
        seats: seats,
        carPark: carPark,
      );
    } catch (e) {
      print('Error getting car by ID $carId: $e');
      return null;
    }
  }

  // Add a new car
  Future<String> addCar(Car car) async {
    final docRef = await _carsCollection.add({
      'brand': car.brand,
      'model': car.model,
      'year': car.year,
      'imageUrl': car.imageUrl,
      'pricePerWeek': car.pricePerWeek,
      'fuelType': car.fuelType,
      'seats': car.seats,
      'carPark': car.carPark,
    });
    return docRef.id;
  }

  // Update a car
  Future<void> updateCar(Car car) async {
    await _carsCollection.doc(car.id).update({
      'brand': car.brand,
      'model': car.model,
      'year': car.year,
      'imageUrl': car.imageUrl,
      'pricePerWeek': car.pricePerWeek,
      'fuelType': car.fuelType,
      'seats': car.seats,
      'carPark': car.carPark,
    });
  }

  // Delete a car
  Future<void> deleteCar(String carId) async {
    await _carsCollection.doc(carId).delete();
  }

  // Get cars by carPark
  Future<List<Car>> getCarsByCarPark(String carPark) async {
    try {
      final snapshot = await _carsCollection.where('carPark', isEqualTo: carPark).get();

      List<Car> cars = [];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;

          // Handle different field naming and null values
          final brand = data['brand'] ?? data['make'] ?? 'Unknown';
          final model = data['model'] ?? 'Unknown';
          final year = data['year'] is int ? data['year'] : 2023;
          final imageUrl = data['imageUrl'] ?? '';
          final pricePerWeek = data['pricePerWeek'] is int ? data['pricePerWeek'] : 0;
          final fuelType = data['fuelType'] ?? 'Unknown';
          final seats = data['seats'] is int ? data['seats'] : 5;
          final carParkName = data['carPark'] ?? 'Unknown';

          cars.add(Car(
            id: doc.id,
            brand: brand,
            model: model,
            year: year,
            imageUrl: imageUrl,
            pricePerWeek: pricePerWeek,
            fuelType: fuelType,
            seats: seats,
            carPark: carParkName,
          ));
        } catch (e) {
          print('Error creating Car from doc ${doc.id} in carPark $carPark: $e');
          // Continue to the next document
        }
      }

      return cars;
    } catch (e) {
      print('Error getting cars by carPark $carPark: $e');
      return [];
    }
  }
}
