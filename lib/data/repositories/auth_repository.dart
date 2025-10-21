import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;
  
  AuthRepository(this._apiClient, this._storage);
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Gunakan method post dari ApiClient Anda
      final response = await _apiClient.post(
        '/login', 
        {
          'username': username,
          'password': password,
        },
      );
      
      // Cek response
      if (response.data['success'] == true) {
        // Simpan token
        await _storage.write(
          key: 'auth_token',
          value: response.data['data']['token'],
        );
        
        // Return user data
        return response.data['data']['user'];
      }
      
      throw Exception(response.data['message'] ?? 'Login gagal');
      
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response?.statusCode == 422) {
        throw Exception('Username atau password salah');
      }
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Koneksi timeout. Cek koneksi internet Anda');
      }
      
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server tidak merespon');
      }
      
      throw Exception(
        e.response?.data['message'] ?? 
        'Terjadi kesalahan: ${e.message}'
      );
      
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      await _apiClient.post('/logout', {});
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _storage.delete(key: 'auth_token');
    }
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}