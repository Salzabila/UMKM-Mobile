import './transaksi.dart';
import './biaya_operasional.dart';

class RekapData {
  final double totalPendapatan;
  final double totalPengeluaran;
  final double labaBersih;
  final List<Transaksi> daftarTransaksi;
  final List<BiayaOperasional> daftarPengeluaran;

  RekapData({
    required this.totalPendapatan,
    required this.totalPengeluaran,
    required this.labaBersih,
    required this.daftarTransaksi,
    required this.daftarPengeluaran,
  });
}