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
      password: 'P@ssw0rd123!',
      firstName: 'Олександр',
      lastName: 'Петренко',
    ),
    MockUserData(
      email: 'mariia.shevchenko@ukr.net',
      password: 'S3cure456&',
      firstName: 'Марія',
      lastName: 'Шевченко',
    ),
    MockUserData(
      email: 'ivan.kovalenko@gmail.com',
      password: 'Iv@n2023\$',
      firstName: 'Іван',
      lastName: 'Коваленко',
    ),
    MockUserData(
      email: 'tetiana.bondar@meta.ua',
      password: 'T@nia1990!',
      firstName: 'Тетяна',
      lastName: 'Бондар',
    ),
    MockUserData(
      email: 'dmytro.tkachenko@gmail.com',
      password: 'Dmy3tr0123*',
      firstName: 'Дмитро',
      lastName: 'Ткаченко',
    ),
    MockUserData(
      email: 'nataliia.kravchuk@ukr.net',
      password: 'N@taKrav25#',
      firstName: 'Наталія',
      lastName: 'Кравчук',
    ),
    MockUserData(
      email: 'sergii.moroz@gmail.com',
      password: 'Fr0st2023!@',
      firstName: 'Сергій',
      lastName: 'Мороз',
    ),
    MockUserData(
      email: 'olena.lysenko@meta.ua',
      password: 'Olen@2000#',
      firstName: 'Олена',
      lastName: 'Лисенко',
    ),
    MockUserData(
      email: 'andriy.boyko@gmail.com',
      password: 'Andr1y1985\$',
      firstName: 'Андрій',
      lastName: 'Бойко',
    ),
    MockUserData(
      email: 'viktoriia.koval@ukr.net',
      password: 'V1k@1234#',
      firstName: 'Вікторія',
      lastName: 'Коваль',
    ),
    MockUserData(
      email: 'mykhailo.ponomarenko@meta.ua',
      password: 'Mykh@1l0123!',
      firstName: 'Михайло',
      lastName: 'Пономаренко',
    ),
    MockUserData(
      email: 'yuliya.savchenko@gmail.com',
      password: 'Yul1y@25&',
      firstName: 'Юлія',
      lastName: 'Савченко',
    ),
  ];
  
  /// Get a random mock user data
  static MockUserData getRandomUser() {
    return _mockUsers[_random.nextInt(_mockUsers.length)];
  }
}
