import '../models/pelanggan.dart';

class PelangganService {
  // TODO: Replace with your database implementation (API, SQLite, etc.)
  final List<Pelanggan> _pelangganList = [];

  Future<List<Pelanggan>> getSemuaPelanggan() async {
    // TODO: Fetch from API or database
    return List.from(_pelangganList);
  }

  Future<void> simpanPelanggan(Pelanggan pelanggan) async {
    // TODO: Save to API or database
    final index = _pelangganList.indexWhere((p) => p.id == pelanggan.id);
    if (index != -1) {
      _pelangganList[index] = pelanggan;
    } else {
      _pelangganList.add(pelanggan);
    }
  }

  Future<void> hapusPelanggan(String id) async {
    // TODO: Delete from API or database
    _pelangganList.removeWhere((p) => p.id == id);
  }
}
