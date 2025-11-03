import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    // Handle Login
    on<AuthLoginRequested>(_onLoginRequested);

    // Handle Logout
    on<AuthLogoutRequested>(_onLogoutRequested);

    // Check if user is already logged in
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final loginResponse = await authRepository.login(
        username: event.username,
        password: event.password,
      );

      emit(AuthAuthenticated(user: loginResponse.user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      // Even if logout fails, clear local state
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final isLoggedIn = await authRepository.isLoggedIn();

      if (isLoggedIn) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
}
