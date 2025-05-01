import '../models/user_model.dart';

class UserService {
  // Mock user data
  User getMockUser() {
    return User(
      id: '1',
      firstName: 'Олександр',
      lastName: 'Петренко',
      email: 'oleksandr.petrenko@example.com',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      isVerified: true,
    );
  }
  
  // This would connect to an API in a real application
  Future<bool> updateUserInfo(User updatedUser) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Always return success for mock implementation
    return true;
  }
}
