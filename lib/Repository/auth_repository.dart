import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';
import '../models/user.dart';
import '../service/dio_client.dart';
import '../config/app_config.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient();

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        AppConfig.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save token to local storage
      await _dioClient.saveToken(loginResponse.token);

      // Save user data to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', loginResponse.user.id);
      await prefs.setString('user_nama', loginResponse.user.nama);
      await prefs.setString('user_username', loginResponse.user.username);
      await prefs.setString('user_role', loginResponse.user.role);

      return loginResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error
        final errorMessage = e.response?.data['message'] ?? 'Login gagal';
        throw Exception(errorMessage);
      } else {
        // Network error
        throw Exception('Koneksi ke server gagal. Periksa internet Anda.');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Call logout API (optional, jika backend memiliki endpoint logout)
      await _dioClient.dio.post(AppConfig.logoutEndpoint);
    } catch (e) {
      // Ignore error, still clear local data
    } finally {
      // Clear token and user data from local storage
      await _dioClient.clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_nama');
      await prefs.remove('user_username');
      await prefs.remove('user_role');
      await prefs.remove('token');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id');
      final nama = prefs.getString('user_nama');
      final username = prefs.getString('user_username');
      final role = prefs.getString('user_role');

      if (id != null && nama != null && username != null && role != null) {
        return User(
          id: id,
          nama: nama,
          username: username,
          role: role,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }
}
