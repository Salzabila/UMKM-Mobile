import '../models/biaya_operasional.dart';

class BiayaOperasionalService {
  // TODO: Replace with your database implementation (API, SQLite, etc.)
  final List<BiayaOperasional> _biayaList = [];

  Future<List<BiayaOperasional>> getSemuaBiaya() async {
    // TODO: Fetch from API or database
    final biaya = List<BiayaOperasional>.from(_biayaList);
    biaya.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return biaya;
  }

  Future<void> simpanBiaya(BiayaOperasional biaya) async {
    // TODO: Save to API or database
    final index = _biayaList.indexWhere((b) => b.id == biaya.id);
    if (index != -1) {
      _biayaList[index] = biaya;
    } else {
      _biayaList.add(biaya);
    }
  }

  Future<void> hapusBiaya(String id) async {
    // TODO: Delete from API or database
    _biayaList.removeWhere((b) => b.id == id);
  }
}
