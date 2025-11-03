import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // TODO: Ganti dengan URL Laravel backend Anda
  static const String baseUrl = 'http://localhost:8000/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get auth token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Upload file (multipart)
  Future<dynamic> uploadFile(
    String endpoint,
    String fieldName,
    String filePath, {
    Map<String, String>? additionalFields,
  }) async {
    try {
      final token = await _getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$endpoint'),
      );

      // Add headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found.');
    } else if (response.statusCode >= 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Request failed');
    }
  }

  // Example usage methods for specific endpoints:

  // Barang endpoints
  Future<List<dynamic>> getBarang() async {
    final response = await get('barang');
    return response['data'] ?? [];
  }

  Future<dynamic> createBarang(Map<String, dynamic> data) async {
    return await post('barang', data);
  }

  Future<dynamic> updateBarang(String id, Map<String, dynamic> data) async {
    return await put('barang/$id', data);
  }

  Future<void> deleteBarang(String id) async {
    await delete('barang/$id');
  }

  // Pelanggan endpoints
  Future<List<dynamic>> getPelanggan() async {
    final response = await get('pelanggan');
    return response['data'] ?? [];
  }

  Future<dynamic> createPelanggan(Map<String, dynamic> data) async {
    return await post('pelanggan', data);
  }

  Future<dynamic> updatePelanggan(String id, Map<String, dynamic> data) async {
    return await put('pelanggan/$id', data);
  }

  Future<void> deletePelanggan(String id) async {
    await delete('pelanggan/$id');
  }

  // Biaya Operasional endpoints
  Future<List<dynamic>> getBiayaOperasional() async {
    final response = await get('biaya-operasional');
    return response['data'] ?? [];
  }

  Future<dynamic> createBiayaOperasional(Map<String, dynamic> data) async {
    return await post('biaya-operasional', data);
  }

  Future<void> deleteBiayaOperasional(String id) async {
    await delete('biaya-operasional/$id');
  }

  // Transaksi endpoints
  Future<List<dynamic>> getTransaksi() async {
    final response = await get('transaksi');
    return response['data'] ?? [];
  }

  Future<dynamic> createTransaksi(Map<String, dynamic> data) async {
    return await post('transaksi', data);
  }

  // Return Barang endpoints
  Future<List<dynamic>> getReturnBarang() async {
    final response = await get('return-barang');
    return response['data'] ?? [];
  }

  Future<dynamic> createReturnBarang(Map<String, dynamic> data) async {
    return await post('return-barang', data);
  }
}
