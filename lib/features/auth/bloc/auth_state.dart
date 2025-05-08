import 'package:equatable/equatable.dart';

import '../models/auth_error_model.dart';
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
  final AuthErrorModel? apiError;

  const AuthFailure(this.error, {this.apiError});

  factory AuthFailure.fromError(dynamic error) {
    if (error is AuthErrorModel) {
      return AuthFailure(
        error.getFirstError(),
        apiError: error,
      );
    }
    return AuthFailure(error.toString());
  }

  bool get hasFieldErrors => apiError != null && apiError!.fieldErrors.isNotEmpty;
  String get allErrors => apiError?.getAllErrors() ?? error;
  Map<String, List<String>> get fieldErrors => apiError?.fieldErrors ?? {};

  @override
  List<Object?> get props => [error, apiError];
}
