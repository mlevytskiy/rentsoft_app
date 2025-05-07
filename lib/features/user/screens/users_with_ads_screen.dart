import 'package:flutter/material.dart';
import 'package:rentsoft_app/features/user/models/user_with_ads_count.dart';
import 'package:rentsoft_app/features/user/repositories/user_repository.dart';
import 'package:rentsoft_app/features/user/screens/user_detail_screen.dart';

class UsersWithAdsScreen extends StatefulWidget {
  const UsersWithAdsScreen({super.key});

  @override
  State<UsersWithAdsScreen> createState() => _UsersWithAdsScreenState();
}

class _UsersWithAdsScreenState extends State<UsersWithAdsScreen> {
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = true;
  List<UserWithAdsCount> _users = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _userRepository.getUsersWithAdsCount();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Користувачі з оголошеннями'),
        backgroundColor: const Color(0xFF3F5185),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Завантаження даних користувачів та їх оголошень...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Помилка завантаження: $_errorMessage'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Спробувати знову'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text('Немає користувачів з оголошеннями'),
      );
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF3F5185),
            child: Text(user.name.substring(0, 1), style: const TextStyle(color: Colors.white)),
          ),
          title: Text('${user.name} ${user.surname}'),
          subtitle: Text('ID: ${user.id}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.adsCount > 0 ? const Color(0xFF3F5185) : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Оголошень: ${user.adsCount}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserDetailScreen(user: user),
              ),
            );
          },
        );
      },
    );
  }
}
