import '../models/barang.dart';
import 'dart:io';
import 'foto_service.dart';

class BarangService {
  final FotoService _fotoService = FotoService();
  static final BarangService _instance = BarangService._internal();
  factory BarangService() => _instance;
  BarangService._internal();

  // TODO: Replace with your database implementation (API, SQLite, etc.)
  final List<Barang> _barangList = [];

  Future<List<Barang>> getBarang() async {
    // TODO: Fetch from API or database
    return List.from(_barangList);
  }

  Future<void> addBarang(Barang barangBaru) async {
    // TODO: Save to API or database
    _barangList.add(barangBaru);
  }

  Future<void> addBarangWithFoto(Barang barang, File? fotoFile) async {
    try {
      String? fotoUrl;
      if (fotoFile != null) {
        fotoUrl = await _fotoService.uploadFoto(fotoFile, barang.id);
      }

      final barangDenganFoto = barang.copyWith(fotoUrl: fotoUrl);
      await addBarang(barangDenganFoto);
    } catch (e) {
      throw Exception('Gagal menambah barang dengan foto: $e');
    }
  }

  Future<void> updateBarangWithFoto(Barang barang, File? fotoFile) async {
    try {
      String? fotoUrl = barang.fotoUrl;

      if (fotoFile != null) {
        if (fotoUrl != null) {
          await _fotoService.hapusFoto(fotoUrl);
        }
        fotoUrl = await _fotoService.uploadFoto(fotoFile, barang.id);
      }

      final barangBaru = barang.copyWith(fotoUrl: fotoUrl);
      await updateBarang(barangBaru);
    } catch (e) {
      throw Exception('Gagal update barang dengan foto: $e');
    }
  }

  Future<void> updateBarang(Barang barang) async {
    // TODO: Update in API or database
    final index = _barangList.indexWhere((b) => b.id == barang.id);
    if (index != -1) {
      _barangList[index] = barang;
    }
  }

  Future<void> hapusBarang(String id) async {
    // TODO: Delete from API or database
    _barangList.removeWhere((b) => b.id == id);
  }

  Future<void> kurangiStok(String idBarang, int jumlah) async {
    final index = _barangList.indexWhere((b) => b.id == idBarang);
    if (index != -1) {
      final barang = _barangList[index];
      final stokBaru = barang.stok - jumlah;
      if (stokBaru < 0) {
        throw Exception('Stok tidak cukup');
      }
      _barangList[index] = barang.copyWith(stok: stokBaru);
    }
  }

  Future<Barang?> getBarangById(String id) async {
    try {
      return _barangList.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method untuk update stok barang (untuk restock)
  Future<void> updateStokBarang(Barang barang, int jumlahTambahan) async {
    // TODO: Update via API or database
    final index = _barangList.indexWhere((b) => b.id == barang.id);
    if (index != -1) {
      final stokBaru = barang.stok + jumlahTambahan;
      _barangList[index] = barang.copyWith(stok: stokBaru);
    }
  }

  // Method untuk delete barang
  Future<void> deleteBarang(String id) async {
    // TODO: Delete via API or database
    _barangList.removeWhere((b) => b.id == id);
  }
}
