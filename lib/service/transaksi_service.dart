import '../models/transaksi.dart';

class TransaksiService {
  // Gunakan pola Singleton agar data riwayat konsisten di seluruh aplikasi
  static final TransaksiService _instance = TransaksiService._internal();
  factory TransaksiService() {
    return _instance;
  }
  TransaksiService._internal();

  // "Tabel" database palsu untuk menyimpan riwayat
  final List<Transaksi> _riwayatTransaksi = [];

  // Fungsi untuk MENGAMBIL semua riwayat
  Future<List<Transaksi>> getRiwayatTransaksi() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulasi jeda
    // Urutkan dari yang paling baru
    _riwayatTransaksi.sort((a, b) => b.waktuTransaksi.compareTo(a.waktuTransaksi));
    return List.from(_riwayatTransaksi);
  }

  // Fungsi untuk MENYIMPAN transaksi baru
  Future<void> simpanTransaksi(Transaksi transaksiBaru) async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulasi jeda
    _riwayatTransaksi.add(transaksiBaru);
  }
}