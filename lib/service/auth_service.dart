import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Gunakan pola Singleton agar konsisten dengan service lain
  static final AuthService _instance = AuthService._internal();
  factory AuthService() {
    return _instance;
  }
  AuthService._internal();

  // GANTI URL INI DENGAN URL API BACKEND ANDA
  static const String _baseUrl = 'https://api.anda.com/v1';

  Future<void> requestPasswordReset(String email) async {
    final url = Uri.parse('$_baseUrl/lupa-password'); // Endpoint untuk lupa password

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode >= 400) {
        throw 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
      }
    } catch (error) {
      throw 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final url = Uri.parse('$_baseUrl/logout');
      try {
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {
        // Jika request gagal, tetap hapus token
      }
    }

    // Hapus token lokal
    await prefs.remove('token');
  }
}