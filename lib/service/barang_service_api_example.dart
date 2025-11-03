import '../models/barang.dart';
import 'api_service.dart';

/// Example implementation of BarangService using Laravel API
/// This is a reference implementation - copy methods to your actual barang_service.dart
class BarangServiceWithAPI {
  final ApiService _apiService = ApiService();

  // Get all barang from API
  Future<List<Barang>> getBarang() async {
    try {
      final response = await _apiService.get('barang');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Barang.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat data barang: $e');
    }
  }

  // Add new barang via API
  Future<void> addBarang(Barang barang) async {
    try {
      await _apiService.post('barang', barang.toJson());
    } catch (e) {
      throw Exception('Gagal menambah barang: $e');
    }
  }

  // Update barang via API
  Future<void> updateBarang(Barang barang) async {
    try {
      await _apiService.put('barang/${barang.id}', barang.toJson());
    } catch (e) {
      throw Exception('Gagal mengupdate barang: $e');
    }
  }

  // Delete barang via API
  Future<void> deleteBarang(String id) async {
    try {
      await _apiService.delete('barang/$id');
    } catch (e) {
      throw Exception('Gagal menghapus barang: $e');
    }
  }

  // Get barang by ID
  Future<Barang?> getBarangById(String id) async {
    try {
      final response = await _apiService.get('barang/$id');
      return Barang.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal memuat data barang: $e');
    }
  }

  // Update stok barang
  Future<void> updateStokBarang(Barang barang, int jumlahTambahan) async {
    try {
      await _apiService.put('barang/${barang.id}/update-stok', {
        'jumlah': jumlahTambahan,
      });
    } catch (e) {
      throw Exception('Gagal mengupdate stok: $e');
    }
  }

  // Kurangi stok barang
  Future<void> kurangiStok(String idBarang, int jumlah) async {
    try {
      await _apiService.put('barang/$idBarang/kurangi-stok', {
        'jumlah': jumlah,
      });
    } catch (e) {
      throw Exception('Gagal mengurangi stok: $e');
    }
  }

  // Add barang with photo upload
  Future<void> addBarangWithFoto(Barang barang, String? fotoPath) async {
    try {
      // First, create barang
      final response = await _apiService.post('barang', barang.toJson());
      final String barangId = response['data']['id'];

      // Then, upload photo if exists
      if (fotoPath != null) {
        await _apiService.uploadFile(
          'upload-foto',
          'foto',
          fotoPath,
          additionalFields: {
            'barang_id': barangId,
            'type': 'barang',
          },
        );
      }
    } catch (e) {
      throw Exception('Gagal menambah barang dengan foto: $e');
    }
  }

  // Update barang with photo
  Future<void> updateBarangWithFoto(Barang barang, String? fotoPath) async {
    try {
      // Update barang data
      await _apiService.put('barang/${barang.id}', barang.toJson());

      // Upload new photo if exists
      if (fotoPath != null) {
        await _apiService.uploadFile(
          'upload-foto',
          'foto',
          fotoPath,
          additionalFields: {
            'barang_id': barang.id,
            'type': 'barang',
          },
        );
      }
    } catch (e) {
      throw Exception('Gagal mengupdate barang dengan foto: $e');
    }
  }
}
