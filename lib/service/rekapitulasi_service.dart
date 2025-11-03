import 'package:aplikasi_umkm/models/rekap_data.dart'; 
import 'package:aplikasi_umkm/models/transaksi.dart';
import 'package:aplikasi_umkm/utils/enums.dart';
import './transaksi_service.dart';

class RekapitulasiService {
  final TransaksiService _transaksiService = TransaksiService();

  Future<RekapData> getRekapData(PeriodeWaktu periode) async {
    final semuaTransaksi = await _transaksiService.getRiwayatTransaksi();
    
    final now = DateTime.now();
    final List<Transaksi> transaksiTerfilter = semuaTransaksi.where((tx) {
      switch (periode) {
        case PeriodeWaktu.hariIni:
          return tx.waktuTransaksi.year == now.year && tx.waktuTransaksi.month == now.month && tx.waktuTransaksi.day == now.day;
        case PeriodeWaktu.mingguIni:
          final awalMinggu = now.subtract(Duration(days: now.weekday - 1));
          return tx.waktuTransaksi.isAfter(awalMinggu);
        case PeriodeWaktu.bulanIni:
          return tx.waktuTransaksi.year == now.year && tx.waktuTransaksi.month == now.month;
        default:
          return false; // Tambahkan default untuk switch
      }
    }).toList();
    
    final double totalPendapatan = transaksiTerfilter.fold(0.0, (sum, tx) => sum + tx.total);
    const double totalPengeluaran = 142823;
    final double labaBersih = totalPendapatan - totalPengeluaran;
    
    return RekapData(
      totalPendapatan: totalPendapatan,
      totalPengeluaran: totalPengeluaran,
      labaBersih: labaBersih,
      daftarTransaksi: transaksiTerfilter,
      daftarPengeluaran: [], // Placeholder
    );
  }
}