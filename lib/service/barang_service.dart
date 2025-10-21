import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/barang.dart';

class BarangService {
  // final FotoService _fotoService = FotoService();
  static final BarangService _instance = BarangService._internal();
  factory BarangService() => _instance;
  BarangService._internal();

  final Box<Barang> _barangBox = Hive.box<Barang>('barangBox');

  Future<List<Barang>> getBarang() async {
    if (_barangBox.isEmpty) {
      await _tambahDataAwal();
    }
    return _barangBox.values.toList();
  }

  Future<void> addBarang(Barang barangBaru) async {
    await _barangBox.put(barangBaru.id, barangBaru);
  }

  // Method baru untuk menambah barang dengan foto
  Future<void> addBarangWithFoto(Barang barang, File? fotoFile) async {
    try {
      String? fotoUrl;
      if (fotoFile != null) {
        // fotoUrl = await _fotoService.uploadFoto(fotoFile, barang.id);
      }
      
      final barangDenganFoto = barang.copyWith(fotoUrl: fotoUrl);
      await addBarang(barangDenganFoto);
    } catch (e) {
      throw Exception('Gagal menambah barang dengan foto: $e');
    }
  }

  // Method untuk update barang dengan foto
  Future<void> updateBarangWithFoto(Barang barang, File? fotoFile) async {
    try {
      String? fotoUrl = barang.fotoUrl;
      
      if (fotoFile != null) {
        // Hapus foto lama jika ada
        if (fotoUrl != null) {
          // await _fotoService.hapusFoto(fotoUrl);
        }
        // Upload foto baru
        // fotoUrl = await _fotoService.uploadFoto(fotoFile, barang.id);
      }
      
      final barangDiupdate = barang.copyWith(fotoUrl: fotoUrl);
      await updateBarang(barangDiupdate);
    } catch (e) {
      throw Exception('Gagal update barang dengan foto: $e');
    }
  }

  // Method untuk update barang biasa
  Future<void> updateBarang(Barang barang) async {
    await _barangBox.put(barang.id, barang);
  }

  Future<void> deleteBarang(String barangId) async {
    await _barangBox.delete(barangId);
  }

  // Method untuk hapus barang dengan foto
  Future<void> deleteBarangWithFoto(String barangId) async {
    final barang = _barangBox.get(barangId);
    if (barang != null && barang.fotoUrl != null) {
      // await _fotoService.hapusFoto(barang.fotoUrl!);
    }
    await deleteBarang(barangId);
  }

  Future<void> updateStokBarang(Barang barang, int tambahanStok) async {
    barang.stok += tambahanStok;
    await barang.save();
  }

  // Method untuk edit produk (nama, jenis, dll)
  Future<void> editBarang(Barang barangLama, String namaBaru, String jenisBaru, int stokBaru, double hargaBaru) async {
    final barangDiupdate = barangLama.copyWith(
      namaBarang: namaBaru,
      jenis: jenisBaru,
      stok: stokBaru,
      harga: hargaBaru,
    );
    await updateBarang(barangDiupdate);
  }

  Future<void> _tambahDataAwal() async {
    final dataAwal = [
      Barang(
        id: 'brg-001',
        namaBarang: 'Kopi Robusta Gayo',
        jenis: 'Minuman',
        tanggalMasuk: DateTime.now(),
        stok: 100,
        harga: 25000,
      ),
      Barang(
        id: 'brg-002',
        namaBarang: 'Susu UHT Cokelat',
        jenis: 'Minuman',
        tanggalMasuk: DateTime.now(),
        expired: DateTime.now().add(const Duration(days: 5)), 
        stok: 50,
        harga: 7500,
      ),
      Barang(
        id: 'brg-003',
        namaBarang: 'Roti Tawar',
        jenis: 'Makanan',
        tanggalMasuk: DateTime.now(),
        expired: DateTime.now().subtract(const Duration(days: 2)), 
        stok: 10,
        harga: 15000,
      ),
    ];

    final Map<String, Barang> dataMap = {
      for (var barang in dataAwal) barang.id: barang
    };
    await _barangBox.putAll(dataMap);
  }
}