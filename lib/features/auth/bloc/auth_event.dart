import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  final bool isAdmin;

  const AuthLoginEvent({
    required this.email, 
    required this.password, 
    this.isAdmin = false,
  });

  @override
  List<Object?> get props => [email, password, isAdmin];
}

class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String surname;

  const AuthRegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.surname,
  });

  @override
  List<Object?> get props => [email, password, name, surname];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthCheckStatusEvent extends AuthEvent {}
