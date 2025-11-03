import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String nama;
  final String username;
  final String role;

  const User({
    required this.id,
    required this.nama,
    required this.username,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      username: json['username'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'role': role,
    };
  }

  @override
  List<Object?> get props => [id, nama, username, role];
}
