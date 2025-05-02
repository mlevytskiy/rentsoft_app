import 'package:equatable/equatable.dart';
import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool isNewUser;
  
  // Для нових користувачів після реєстрації
  factory AuthAuthenticated.newUser(UserModel user) {
    return AuthAuthenticated(user, isNewUser: true);
  }
  
  // Для існуючих, які входять в систему
  factory AuthAuthenticated.existingUser(UserModel user) {
    return AuthAuthenticated(user, isNewUser: false);
  }
  
  const AuthAuthenticated(this.user, {this.isNewUser = false});
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  
  const AuthFailure(this.message);
  
  @override
  List<Object?> get props => [message];
}
