import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentsoft_app/features/auth/bloc/auth_bloc.dart';
import 'package:rentsoft_app/features/auth/bloc/auth_event.dart';
import 'package:rentsoft_app/features/auth/models/user_model.dart';

import '../../../core/di/service_locator.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../widgets/verification_status_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _authRepository = getIt<AuthRepository>();
  bool _isEditing = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  VerificationStatus _verificationStatus = VerificationStatus.notVerified;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initControllers();
  }

  Future<void> _loadUserData() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      setState(() {
        _firstName = user.profile?.name ?? "";
        _lastName = user.profile?.surname ?? "";
        _email = user.email;
        _verificationStatus = user.profile?.verificationStatus ?? VerificationStatus.notVerified;

        // Update controllers if already initialized
        _firstNameController.text = _firstName;
        _lastNameController.text = _lastName;
        _emailController.text = _email;
      });
    }
  }

  void _initControllers() {
    _firstNameController = TextEditingController(text: _firstName);
    _lastNameController = TextEditingController(text: _lastName);
    _emailController = TextEditingController(text: _email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserAvatar(),
                const SizedBox(height: 24),
                if (_isEditing) ...[
                  // In edit mode, show the edit boxes
                  // Name and surname in a row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: "Ім'я",
                          icon: Icons.person,
                          enabled: _isEditing,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: 'Прізвище',
                          icon: Icons.person_outline,
                          enabled: _isEditing,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Електронна адреса',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    enabled: _isEditing,
                  ),
                ] else ...[
                  // In view mode, just show text
                  Center(
                    child: Text(
                      '$_firstName $_lastName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                VerificationStatusWidget(status: _verificationStatus),
                const SizedBox(height: 24),
                _buildEditButton(),
                const SizedBox(height: 16),
                _buildLogoutButton(
                  label: 'Вийти з облікового запису',
                  color: const Color(0xFF3F5185), // Navy blue color
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _loadUserData(); // Reset to original values
                      });
                    },
                    child: const Text('Скасувати'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            // Використовуємо іконку замість мережевого зображення
            child: const Icon(
              Icons.person,
              size: 50,
              color: Color(0xFF3F5185),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: const Color(0xFF3F5185),
                border: Border.all(color: Colors.white, width: 2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_isEditing) {
            _saveChanges();
          } else {
            setState(() {
              _isEditing = true;
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F5185), // Navy blue color
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          _isEditing ? 'Зберегти зміни' : 'Змінити дані',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLogoutButton({
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Show confirmation dialog before logout
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Вихід з облікового запису'),
              content: const Text('Ви впевнені, що хочете вийти?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Скасувати'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white, // Setting text color to white
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop(); // Закриваємо діалог

                    // Викликаємо ЛИШЕ метод logout з репозиторію напряму,
                    // без виклику події AuthLogoutEvent
                    print('DEBUG: AccountScreen - прямий виклик logout з репозиторію');
                    await _authRepository.logout();

                    // Додаємо подію AuthCheckStatusEvent замість AuthLogoutEvent
                    // Це змусить блок перевірити стан авторизації заново
                    print('DEBUG: AccountScreen - надсилаємо подію AuthCheckStatusEvent');
                    if (context.mounted) {
                      context.read<AuthBloc>().add(AuthCheckStatusEvent());

                      // Додаємо затримку для обробки події
                      await Future.delayed(const Duration(milliseconds: 300));

                      // Також додаємо явну навігацію на екран авторизації
                      if (context.mounted) {
                        print('DEBUG: AccountScreen - явна навігація на екран логіну');
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    }
                  },
                  child: const Text('Вийти'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon, // Keeping parameter but not using it
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              // Remove labelText to use custom positioned label
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF3F5185)),
              ),
              contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            ),
            keyboardType: keyboardType,
            enabled: enabled,
          ),
          // Custom positioned label
          Positioned(
            left: 16,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    setState(() {
      _firstName = _firstNameController.text;
      _lastName = _lastNameController.text;
      _email = _emailController.text;
      _isEditing = false;
    });

    // Note: In a real app, we would update these values in the repository
    // For now, we're just updating the UI

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Дані успішно оновлено')),
    );
  }
}
