import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/rekap_data.dart';
import '../utils/enums.dart';

class WidgetLaporan extends StatelessWidget {
  final RekapData data;
  final PeriodeWaktu periode;
  const WidgetLaporan({super.key, required this.data, required this.periode});

  @override
  Widget build(BuildContext context) {
    String periodeTeks;
    switch (periode) {
      case PeriodeWaktu.hariIni: periodeTeks = "HARIAN"; break;
      case PeriodeWaktu.mingguIni: periodeTeks = "MINGGUAN"; break;
      case PeriodeWaktu.bulanIni: periodeTeks = "BULANAN"; break;
      default: periodeTeks = "PERIODE KUSTOM";
    }
    
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      width: 300, // Lebar umum untuk kertas struk 58mm
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.black, fontFamily: 'monospace', fontSize: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Text('LAPORAN PENJUALAN', style: _boldStyle(14))),
            Center(child: Text(periodeTeks)),
            Center(child: Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()))),
            _divider(),
            _buildRow('TOTAL PENDAPATAN', 'Rp ${formatter.format(data.totalPendapatan)}'),
            _buildRow('TOTAL PENGELUARAN', 'Rp ${formatter.format(data.totalPengeluaran)}'),
            _divider(),
            _buildRow('LABA BERSIH', 'Rp ${formatter.format(data.labaBersih)}', isBold: true),
            _divider(),
            Text('DETAIL PENDAPATAN (${data.daftarTransaksi.length} trx):', style: _boldStyle()),
            const SizedBox(height: 4),
            ...data.daftarTransaksi.map((tx) => _buildRow(
              '  - ${tx.nomerNota}',
              'Rp ${formatter.format(tx.total)}'
            )),
            const SizedBox(height: 8),
            Text('DETAIL PENGELUARAN (${data.daftarPengeluaran.length} item):', style: _boldStyle()),
            if (data.daftarPengeluaran.isEmpty) const Text('  - Tidak ada'),
            // TODO: Tambahkan loop untuk daftar pengeluaran di sini
            _divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? _boldStyle() : null),
          Text(value, style: isBold ? _boldStyle() : null),
        ],
      ),
    );
  }

  Widget _divider() => const Text('--------------------------------');

  TextStyle _boldStyle([double size = 12]) => TextStyle(fontWeight: FontWeight.bold, fontSize: size);
}