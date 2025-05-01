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

  final List<Widget> _tabs = const [
    MyCarsScreen(),
    CarSearchScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        // Removed AppBar to save vertical space
        body: Navigator(
          onGenerateRoute: (settings) {
            if (settings.name == '/') {
              return MaterialPageRoute(
                builder: (context) => _tabs[_currentIndex],
                settings: settings,
              );
            }
            // Add other routes if needed
            return null;
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
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
