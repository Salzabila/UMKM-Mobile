import 'user.dart';

class LoginResponse {
  final bool success;
  final String message;
  final User user;
  final String token;
  final String tokenType;

  LoginResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      user: User.fromJson(json['data']['user']),
      token: json['data']['token'],
      tokenType: json['data']['token_type'],
    );
  }
}
