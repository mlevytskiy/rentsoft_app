import 'dart:math';

class MockUserData {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  MockUserData({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
}

class MockDataService {
  static final Random _random = Random();
  
  // List of mock user data
  static final List<MockUserData> _mockUsers = [
    MockUserData(
      email: 'oleksandr.petrenko@gmail.com',
      password: 'password123',
      firstName: 'Олександр',
      lastName: 'Петренко',
    ),
    MockUserData(
      email: 'mariia.shevchenko@ukr.net',
      password: 'secure456',
      firstName: 'Марія',
      lastName: 'Шевченко',
    ),
    MockUserData(
      email: 'ivan.kovalenko@gmail.com',
      password: 'ivan2023',
      firstName: 'Іван',
      lastName: 'Коваленко',
    ),
    MockUserData(
      email: 'tetiana.bondar@meta.ua',
      password: 'tania1990',
      firstName: 'Тетяна',
      lastName: 'Бондар',
    ),
    MockUserData(
      email: 'dmytro.tkachenko@gmail.com',
      password: 'dmytro123',
      firstName: 'Дмитро',
      lastName: 'Ткаченко',
    ),
    MockUserData(
      email: 'nataliia.kravchuk@ukr.net',
      password: 'natakrav',
      firstName: 'Наталія',
      lastName: 'Кравчук',
    ),
    MockUserData(
      email: 'sergii.moroz@gmail.com',
      password: 'frost2023',
      firstName: 'Сергій',
      lastName: 'Мороз',
    ),
    MockUserData(
      email: 'olena.lysenko@meta.ua',
      password: 'olena2000',
      firstName: 'Олена',
      lastName: 'Лисенко',
    ),
    MockUserData(
      email: 'andriy.boyko@gmail.com',
      password: 'andriy1985',
      firstName: 'Андрій',
      lastName: 'Бойко',
    ),
    MockUserData(
      email: 'viktoriia.koval@ukr.net',
      password: 'vika1234',
      firstName: 'Вікторія',
      lastName: 'Коваль',
    ),
    MockUserData(
      email: 'mykhailo.ponomarenko@meta.ua',
      password: 'mykhail0',
      firstName: 'Михайло',
      lastName: 'Пономаренко',
    ),
    MockUserData(
      email: 'yuliya.savchenko@gmail.com',
      password: 'yuliya25',
      firstName: 'Юлія',
      lastName: 'Савченко',
    ),
  ];
  
  /// Get a random mock user data
  static MockUserData getRandomUser() {
    return _mockUsers[_random.nextInt(_mockUsers.length)];
  }
}
