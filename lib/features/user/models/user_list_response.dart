import 'package:rentsoft_app/features/auth/models/user_model.dart';

class UserListResponse {
  final List<UserModel> users;

  UserListResponse({required this.users});

  factory UserListResponse.fromJson(List<dynamic> json) {
    List<UserModel> users = json.map((userData) => UserModel.fromJson(userData)).toList();
    return UserListResponse(users: users);
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'UserListResponse{users: $users}';
  }
}
