import 'package:equatable/equatable.dart';

/// Semua event untuk AuthBloc
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  AuthLoginRequested(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
