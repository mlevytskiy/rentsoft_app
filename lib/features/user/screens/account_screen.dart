import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/verification_status.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _userService = UserService();
  late User _user;
  bool _isEditing = false;
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  
  @override
  void initState() {
    super.initState();
    _user = _userService.getMockUser();
    _initControllers();
  }
  
  void _initControllers() {
    _firstNameController = TextEditingController(text: _user.firstName);
    _lastNameController = TextEditingController(text: _user.lastName);
    _emailController = TextEditingController(text: _user.email);
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
      body: SingleChildScrollView(
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
                    '${_user.firstName} ${_user.lastName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              VerificationStatus(isVerified: _user.isVerified),
              const SizedBox(height: 24),
              _buildEditButton(),
              if (_isEditing) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _initControllers(); // Reset controllers to original values
                    });
                  },
                  child: const Text('Скасувати'),
                ),
              ],
            ],
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
            radius: 60,
            backgroundImage: NetworkImage(_user.avatarUrl),
            onBackgroundImageError: (_, __) {
              // Handle image loading error
            },
          ),
          if (_isEditing)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
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
                borderSide: BorderSide(color: const Color(0xFF3F5185)),
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
    final updatedUser = _user.copyWith(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
    );
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    // Simulate API call
    final success = await _userService.updateUserInfo(updatedUser);
    
    // Hide loading indicator
    Navigator.pop(context);
    
    if (success) {
      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дані успішно оновлено')),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Помилка під час оновлення даних')),
      );
    }
  }
}
