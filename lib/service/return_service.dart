import '../models/return_barang.dart';

class ReturnService {
  // TODO: Replace with your database implementation (API, SQLite, etc.)
  final List<ReturnBarang> _returnList = [];

  Future<List<ReturnBarang>> getSemuaReturn() async {
    // TODO: Fetch from API or database
    final daftarReturn = List<ReturnBarang>.from(_returnList);
    daftarReturn.sort((a, b) => b.tanggalReturn.compareTo(a.tanggalReturn));
    return daftarReturn;
  }

  Future<void> simpanReturn(ReturnBarang returnBaru) async {
    // TODO: Save to API or database
    final index = _returnList.indexWhere((r) => r.id == returnBaru.id);
    if (index != -1) {
      _returnList[index] = returnBaru;
    } else {
      _returnList.add(returnBaru);
    }
  }

  Future<void> hapusReturn(String id) async {
    // TODO: Delete from API or database
    _returnList.removeWhere((r) => r.id == id);
  }
}
