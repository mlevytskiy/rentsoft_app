import '../../../core/api/api_client.dart';
import '../models/car_model.dart';
import 'i_car_repository.dart';

class CarRepository implements ICarRepository {
  final ApiClient _apiClient;
  
  CarRepository() : _apiClient = ApiClient();
  
  @override
  Future<List<Car>> getCars() async {
    try {
      final response = await _apiClient.get('/cars');
      
      if (response.statusCode == 200) {
        final List<dynamic> carsData = response.data;
        return carsData.map((car) => _mapToCar(car)).toList();
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      print('Error fetching cars: $e');
      return _getMockCars();
    }
  }
  
  @override
  Future<Car?> getCarById(String id) async {
    try {
      final response = await _apiClient.get('/cars/$id');
      
      if (response.statusCode == 200) {
        return _mapToCar(response.data);
      } else {
        throw Exception('Failed to load car details: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      print('Error fetching car details: $e');
      return _getMockCars().firstWhere((car) => car.id == id, orElse: () => throw Exception('Car not found'));
    }
  }
  
  @override
  Future<void> bookCar(String carId) async {
    try {
      await _apiClient.post('/cars/$carId/book');
    } catch (e) {
      print('Error booking car: $e');
      throw Exception('Failed to book car');
    }
  }
  
  @override
  Future<void> unbookCar(String carId) async {
    try {
      await _apiClient.post('/cars/$carId/unbook');
    } catch (e) {
      print('Error unbooking car: $e');
      throw Exception('Failed to unbook car');
    }
  }
  
  @override
  Future<void> rejectBooking(String bookingId) async {
    try {
      print('DEBUG: Rejecting booking with ID $bookingId');
      await _apiClient.delete('/bookings/$bookingId');
      print('DEBUG: Booking successfully rejected');
    } catch (e) {
      print('Error rejecting booking: $e');
      throw Exception('Failed to reject booking');
    }
  }
  
  // Map JSON response to Car model
  Car _mapToCar(Map<String, dynamic> data) {
    return Car(
      id: data['id']?.toString() ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 2023,
      // Використовуємо пустий рядок замість зовнішнього посилання
      imageUrl: data['imageUrl'] ?? '',
      pricePerWeek: data['pricePerWeek'] ?? 0,
      fuelType: data['fuelType'] ?? 'Бензин',
      seats: data['seats'] ?? 5,
      carPark: data['carPark'] ?? 'Автопарк 1',
    );
  }
  
  // Mock data for fallback and testing
  List<Car> _getMockCars() {
    return [
      Car(
        id: '1',
        brand: 'Ford',
        model: 'Mustang',
        year: 2021,
        imageUrl: 'https://cdn3.riastatic.com/photosnew/auto/photo/ford_mustang__479482273f.jpg',
        pricePerWeek: 4000,
        fuelType: 'Бензин',
        seats: 4,
        carPark: 'Автопарк 1',
      ),
      Car(
        id: '2',
        brand: 'BMW',
        model: 'X5',
        year: 2022,
        imageUrl: 'https://cdn3.riastatic.com/photosnew/auto/photo/bmw_x5__478624404f.jpg',
        pricePerWeek: 3500,
        fuelType: 'Дизель',
        seats: 5,
        carPark: 'Автопарк 2',
      ),
      Car(
        id: '3',
        brand: 'Mercedes-Benz',
        model: 'E-Class',
        year: 2021,
        imageUrl: 'https://cdn3.riastatic.com/photosnew/auto/photo/mercedes-benz_e-class__478453219f.jpg',
        pricePerWeek: 3200,
        fuelType: 'Бензин',
        seats: 5,
        carPark: 'Автопарк 3',
      ),
      Car(
        id: '4',
        brand: 'Audi',
        model: 'A6',
        year: 2020,
        imageUrl: 'https://cdn1.riastatic.com/photosnew/auto/photo/audi_a6__478906291f.jpg',
        pricePerWeek: 2800,
        fuelType: 'Дизель',
        seats: 5,
        carPark: 'Автопарк 1',
      ),
      Car(
        id: '5',
        brand: 'Toyota',
        model: 'Camry',
        year: 2022,
        imageUrl: 'https://cdn0.riastatic.com/photosnew/auto/photo/toyota_camry__478977840f.jpg',
        pricePerWeek: 2000,
        fuelType: 'Гібрид',
        seats: 5,
        carPark: 'Автопарк 2',
      ),
      Car(
        id: '6',
        brand: 'Volkswagen',
        model: 'Touareg',
        year: 2021,
        imageUrl: 'https://cdn4.riastatic.com/photosnew/auto/photo/volkswagen_touareg__478747744f.jpg',
        pricePerWeek: 3000,
        fuelType: 'Дизель',
        seats: 5,
        carPark: 'Автопарк 3',
      ),
      Car(
        id: '7',
        brand: 'Skoda',
        model: 'Kodiaq',
        year: 2022,
        imageUrl: 'https://cdn1.riastatic.com/photosnew/auto/photo/skoda_kodiaq__475743581f.jpg',
        pricePerWeek: 2200,
        fuelType: 'Бензин',
        seats: 7,
        carPark: 'Автопарк 1',
      ),
      Car(
        id: '8',
        brand: 'Nissan',
        model: 'X-Trail',
        year: 2020,
        imageUrl: 'https://cdn0.riastatic.com/photosnew/auto/photo/nissan_x-trail__474997350f.jpg',
        pricePerWeek: 1900,
        fuelType: 'Дизель',
        seats: 5,
        carPark: 'Автопарк 2',
      ),
      Car(
        id: '9',
        brand: 'Lexus',
        model: 'RX',
        year: 2019,
        imageUrl: 'https://cdn0.riastatic.com/photosnew/auto/photo/lexus_rx__476599670f.jpg',
        pricePerWeek: 2800,
        fuelType: 'Гібрид',
        seats: 5,
        carPark: 'Автопарк 3',
      ),
      Car(
        id: '10',
        brand: 'Tesla',
        model: 'Model 3',
        year: 2021,
        imageUrl: 'https://cdn3.riastatic.com/photosnew/auto/photo/tesla_model-3__478766843f.jpg',
        pricePerWeek: 3300,
        fuelType: 'Електро',
        seats: 5,
        carPark: 'Автопарк 1',
      ),
      Car(
        id: '11',
        brand: 'Porsche',
        model: 'Cayenne',
        year: 2020,
        imageUrl: 'https://cdn4.riastatic.com/photosnew/auto/photo/porsche_cayenne__477824654f.jpg',
        pricePerWeek: 3900,
        fuelType: 'Бензин',
        seats: 5,
        carPark: 'Автопарк 2',
      ),
      Car(
        id: '12',
        brand: 'Mazda',
        model: 'CX-5',
        year: 2021,
        imageUrl: 'https://cdn0.riastatic.com/photosnew/auto/photo/mazda_cx-5__477947990f.jpg',
        pricePerWeek: 1800,
        fuelType: 'Бензин',
        seats: 5,
        carPark: 'Автопарк 3',
      ),
      Car(
        id: '13',
        brand: 'Honda',
        model: 'CR-V',
        year: 2019,
        imageUrl: 'https://cdn0.riastatic.com/photosnew/auto/photo/honda_cr-v__476532410f.jpg',
        pricePerWeek: 1700,
        fuelType: 'Бензин',
        seats: 5,
        carPark: 'Автопарк 1',
      ),
      Car(
        id: '14',
        brand: 'Hyundai',
        model: 'Santa Fe',
        year: 2022,
        imageUrl: 'https://cdn1.riastatic.com/photosnew/auto/photo/hyundai_santa-fe__476893981f.jpg',
        pricePerWeek: 2100,
        fuelType: 'Дизель',
        seats: 7,
        carPark: 'Автопарк 2',
      ),
      Car(
        id: '15',
        brand: 'Kia',
        model: 'Sportage',
        year: 2021,
        imageUrl: 'https://cdn4.riastatic.com/photosnew/auto/photo/kia_sportage__476835904f.jpg',
        pricePerWeek: 1800,
        fuelType: 'Дизель',
        seats: 5,
        carPark: 'Автопарк 3',
      ),
      Car(
        id: '16',
        brand: 'Volvo',
        model: 'XC90',
        year: 2020,
        imageUrl: 'https://cdn0.riastatic.com/photosnew/auto/photo/volvo_xc90__478211100f.jpg',
        pricePerWeek: 3100,
        fuelType: 'Гібрид',
        seats: 7,
        carPark: 'Автопарк 1',
      ),
      Car(
        id: '17',
        brand: 'Land Rover',
        model: 'Range Rover',
        year: 2019,
        imageUrl: 'https://cdn1.riastatic.com/photosnew/auto/photo/land-rover_range-rover__478654501f.jpg',
        pricePerWeek: 3800,
        fuelType: 'Дизель',
        seats: 5,
        carPark: 'Автопарк 2',
      ),
      Car(
        id: '18',
        brand: 'Jeep',
        model: 'Grand Cherokee',
        year: 2021,
        imageUrl: 'https://cdn3.riastatic.com/photosnew/auto/photo/jeep_grand-cherokee__476884573f.jpg',
        pricePerWeek: 2700,
        fuelType: 'Бензин',
        seats: 5,
        carPark: 'Автопарк 3',
      ),
      Car(
        id: '19',
        brand: 'Renault',
        model: 'Koleos',
        year: 2020,
        imageUrl: 'https://cdn0.riastatic.com/photosnew/auto/photo/renault_koleos__477183690f.jpg',
        pricePerWeek: 1600,
        fuelType: 'Дизель',
        seats: 5,
        carPark: 'Автопарк 1',
      ),
      Car(
        id: '20',
        brand: 'Chevrolet',
        model: 'Camaro',
        year: 2022,
        imageUrl: 'https://cdn4.riastatic.com/photosnew/auto/photo/chevrolet_camaro__475632394f.jpg',
        pricePerWeek: 3700,
        fuelType: 'Бензин',
        seats: 4,
        carPark: 'Автопарк 2',
      ),
    ];
  }
}
