import 'transaksi.dart';

class DashboardData {
  final double pendapatan;
  final int transaksiSukses;
  final int barangKeluar;
  final double biayaOperasional;
  final List<double> dataGrafikPendapatan; 
  final List<Transaksi> aktivitasTerbaru;

  DashboardData({
    required this.pendapatan,
    required this.transaksiSukses,
    required this.barangKeluar,
    required this.biayaOperasional,
    required this.dataGrafikPendapatan,
    required this.aktivitasTerbaru,
  });
}