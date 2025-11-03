import '../models/barang.dart';
import './barang_service.dart';

// Model untuk membawa data notifikasi
class NotifikasiProduk {
  final Barang barang;
  final int hariMenujuExpired;

  NotifikasiProduk({required this.barang, required this.hariMenujuExpired});
}

// Service untuk logika pengecekan
class NotifikasiService {
  final BarangService _barangService = BarangService();

  Future<List<NotifikasiProduk>> cekProdukKedaluwarsa({int batasHari = 30}) async {
    final semuaProduk = await _barangService.getBarang();
    final List<NotifikasiProduk> produkBermasalah = [];
    final hariIni = DateTime.now();

    for (var produk in semuaProduk) {
      if (produk.expired != null) {
        final selisih = produk.expired!.difference(hariIni).inDays;
        
        // Cek jika sudah lewat (negatif/0) atau akan expired dalam batasHari
        if (selisih <= batasHari) {
          produkBermasalah.add(
            NotifikasiProduk(barang: produk, hariMenujuExpired: selisih),
          );
        }
      }
    }

    // Urutkan dari yang paling mendesak
    produkBermasalah.sort((a, b) => a.hariMenujuExpired.compareTo(b.hariMenujuExpired));
    
    return produkBermasalah;
  }
}