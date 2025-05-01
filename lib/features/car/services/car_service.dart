import '../models/car_model.dart';

class CarService {
  // Singleton pattern
  static final CarService _instance = CarService._internal();
  factory CarService() => _instance;
  CarService._internal();

  // Track booked cars
  final List<String> _bookedCarIds = [];

  void bookCar(String carId) {
    if (!_bookedCarIds.contains(carId)) {
      _bookedCarIds.add(carId);
    }
  }

  void unbookCar(String carId) {
    _bookedCarIds.remove(carId);
  }

  bool isCarBooked(String carId) {
    return _bookedCarIds.contains(carId);
  }

  List<Car> getBookedCars() {
    return getMockCars().where((car) => _bookedCarIds.contains(car.id)).toList();
  }

  List<Car> getAvailableCars() {
    return getMockCars().where((car) => !_bookedCarIds.contains(car.id)).toList();
  }

  // Mock data for 20 different cars
  List<Car> getMockCars() {
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

  // Filter cars by search query
  List<Car> filterCarsByQuery(String query) {
    if (query.isEmpty) {
      return getMockCars();
    }

    final lowercaseQuery = query.toLowerCase();
    return getMockCars().where((car) {
      final fullName = car.fullName.toLowerCase();
      return fullName.contains(lowercaseQuery);
    }).toList();
  }

  // Filter cars by various parameters
  List<Car> filterCars({
    String? query,
    int? minPrice,
    int? maxPrice,
    String? brand,
    int? seats,
    String? fuelType,
    String? carPark,
  }) {
    var cars = query != null && query.isNotEmpty
        ? filterCarsByQuery(query)
        : getMockCars();

    if (minPrice != null) {
      cars = cars.where((car) => car.pricePerWeek >= minPrice).toList();
    }

    if (maxPrice != null) {
      cars = cars.where((car) => car.pricePerWeek <= maxPrice).toList();
    }

    if (brand != null && brand.isNotEmpty) {
      cars = cars.where((car) => car.brand == brand).toList();
    }

    if (seats != null) {
      cars = cars.where((car) => car.seats >= seats).toList();
    }

    if (fuelType != null && fuelType.isNotEmpty) {
      cars = cars.where((car) => car.fuelType == fuelType).toList();
    }

    if (carPark != null && carPark.isNotEmpty) {
      cars = cars.where((car) => car.carPark == carPark).toList();
    }

    return cars;
  }
}
