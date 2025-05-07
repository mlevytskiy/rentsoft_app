class CarModel {
  final String brand;
  final String model;
  final int year;
  final String color;
  final double engineVolume;
  final String fuelType;
  final String transmission;
  final int mileage;
  final String vin;
  final double price;
  final String photo;

  CarModel({
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.engineVolume,
    required this.fuelType,
    required this.transmission,
    required this.mileage,
    required this.vin,
    required this.price,
    required this.photo,
  });

  Map<String, dynamic> toJson() {
    return {
      'car_brand': brand,
      'car_model': model,
      'engine': engineVolume.toString(),
      'vin': vin,
      'insurance': 'Стандартна',
      'price': price,
      'price_period': 'день',
      'mileage': mileage.toString(),
      'pledge': true,
      'purpose': 'Оренда',
      'driver': false,
      'comment': 'Автомобіль $brand $model, $year рік, $color колір, $fuelType, пробіг $mileage км.',
      'location': 'Київ',
      'fuel_type': [1],
      'transmission': 1,
      'category': 1,
      'status': 1,
    };
  }
}
