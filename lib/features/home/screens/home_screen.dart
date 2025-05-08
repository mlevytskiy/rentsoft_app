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

  @override
  void initState() {
    super.initState();
    // Створюємо унікальний ключ для цього екземпляру екрану
    _myCarsScreenKey = createMyCarsScreenKey();
  }

  late final List<Widget> _tabs = [
    // Використовуємо унікальний ключ для цього екрану
    MyCarsScreen(key: _myCarsScreenKey),
    const CarSearchScreen(),
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
            // При перемиканні на вкладку "Мої авто" (індекс 0), оновлюємо список автомобілів
            if (index == 0 && _myCarsScreenKey.currentState != null) {
              _myCarsScreenKey.currentState!.reloadBookedCars();
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
