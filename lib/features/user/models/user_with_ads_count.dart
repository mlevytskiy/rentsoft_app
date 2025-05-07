class UserWithAdsCount {
  final int id;
  final String name;
  final String surname;
  final int adsCount;

  UserWithAdsCount({
    required this.id,
    required this.name,
    required this.surname,
    required this.adsCount,
  });

  @override
  String toString() {
    return '$name $surname ($adsCount)';
  }
}
