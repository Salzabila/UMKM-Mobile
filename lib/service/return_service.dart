import 'package:hive_flutter/hive_flutter.dart';
import '../models/return_barang.dart';

class ReturnService {
  final Box<ReturnBarang> _returnBox = Hive.box<ReturnBarang>('returnBox');

  // Mengambil semua data return, diurutkan dari yang terbaru
  Future<List<ReturnBarang>> getSemuaReturn() async {
    final daftarReturn = _returnBox.values.toList();
    daftarReturn.sort((a, b) => b.tanggalReturn.compareTo(a.tanggalReturn));
    return daftarReturn;
  }

  // Menyimpan data return baru
  Future<void> simpanReturn(ReturnBarang returnBaru) async {
    await _returnBox.put(returnBaru.id, returnBaru);
  }

  // Menghapus data return (jika diperlukan)
  Future<void> hapusReturn(String id) async {
    await _returnBox.delete(id);
  }
}