class Car {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String imageUrl;
  final int pricePerWeek;
  final String fuelType;
  final int seats;
  final String carPark;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.imageUrl,
    required this.pricePerWeek,
    required this.fuelType,
    required this.seats,
    required this.carPark,
  });

  String get fullName => '$brand $model $year';
}
