import 'package:flutter/material.dart';
import '../../../features/car/screens/car_search_screen.dart';
import '../../../features/car/screens/my_cars_screen.dart';
import '../../../features/user/screens/account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Start with search tab by default
  late final GlobalKey<MyCarsScreenState> _myCarsScreenKey;
  late final GlobalKey<CarSearchScreenState> _carSearchScreenKey;
  // We don't need to store a carService instance as each tab has its own instance

  @override
  void initState() {
    super.initState();
    // Створюємо унікальні ключі для екранів, щоб мати доступ до їх стану
    _myCarsScreenKey = createMyCarsScreenKey();
    _carSearchScreenKey = createCarSearchScreenKey();
  }

  late final List<Widget> _tabs = [
    // Використовуємо унікальні ключі для екранів
    MyCarsScreen(key: _myCarsScreenKey),
    CarSearchScreen(key: _carSearchScreenKey),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        // Використовуємо IndexedStack замість Navigator для уникнення проблем з вкладеними навігаторами
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // При перемиканні на вкладку "Мої авто" (індекс 0), оновлюємо список заброньованих автомобілів
            if (index == 0 && _myCarsScreenKey.currentState != null) {
              _myCarsScreenKey.currentState!.reloadBookedCars();
            }
            
            // При перемиканні на вкладку "Пошук авто" (індекс 1), оновлюємо список доступних автомобілів
            if (index == 1 && _carSearchScreenKey.currentState != null) {
              _carSearchScreenKey.currentState!.reloadCars();
            }
            
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Мої авто',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Пошук',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Акаунт',
            ),
          ],
        ),
      ),
    );
  }
  
  Future<bool> _handleBackNavigation() async {
    // Add your back navigation logic here if needed
    return true; // Allow back navigation
  }
}
