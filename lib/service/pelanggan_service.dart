import 'package:hive_flutter/hive_flutter.dart';
import '../models/pelanggan.dart';

class PelangganService {
  final Box<Pelanggan> _pelangganBox = Hive.box<Pelanggan>('pelangganBox');

  Future<List<Pelanggan>> getSemuaPelanggan() async {
    return _pelangganBox.values.toList();
  }

  Future<void> simpanPelanggan(Pelanggan pelanggan) async {
    await _pelangganBox.put(pelanggan.id, pelanggan);
  }

  Future<void> hapusPelanggan(String id) async {
    await _pelangganBox.delete(id);
  }
}