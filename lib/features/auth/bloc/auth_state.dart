import 'package:equatable/equatable.dart';

import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthAdminResponse extends AuthState {
  final dynamic responseData;

  const AuthAdminResponse(this.responseData);

  @override
  List<Object?> get props => [responseData];
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool isNewUser;

  const AuthAuthenticated({required this.user, required this.isNewUser});

  // Factory constructor для зручності створення стану для існуючого користувача
  factory AuthAuthenticated.existingUser(UserModel user) => AuthAuthenticated(user: user, isNewUser: false);

  // Factory constructor для зручності створення стану для нового користувача
  factory AuthAuthenticated.newUser(UserModel user) => AuthAuthenticated(user: user, isNewUser: true);

  @override
  List<Object?> get props => [user, isNewUser];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}
