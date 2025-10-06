import 'package:hive_flutter/hive_flutter.dart';
import '../models/biaya_operasional.dart';

class BiayaOperasionalService {
  final Box<BiayaOperasional> _biayaBox = Hive.box<BiayaOperasional>('biayaBox');

  Future<List<BiayaOperasional>> getSemuaBiaya() async {
    final biaya = _biayaBox.values.toList();
    biaya.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return biaya;
  }

  Future<void> simpanBiaya(BiayaOperasional biaya) async {
    await _biayaBox.put(biaya.id, biaya);
  }

  Future<void> hapusBiaya(String id) async {
    await _biayaBox.delete(id);
  }
}