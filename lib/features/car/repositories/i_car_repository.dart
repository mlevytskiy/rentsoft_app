import '../models/car_model.dart';

abstract class ICarRepository {
  Future<List<Car>> getCars();
  Future<Car?> getCarById(String id);
  Future<void> bookCar(String carId);
  Future<void> unbookCar(String carId);
  
  /// Відхилити/скасувати бронювання за його ID
  Future<void> rejectBooking(String bookingId);
}
