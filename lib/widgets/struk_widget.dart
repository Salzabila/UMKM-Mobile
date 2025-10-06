import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';

class WidgetStruk extends StatelessWidget {
  final Transaksi transaksi;
  const WidgetStruk({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    // Hitung subtotal dan diskon dari transaksi.items (yang merupakan List<KeranjangItem>)
    final subtotal = transaksi.items.fold(0.0, (sum, item) => sum + (item.barang.harga * item.kuantitas));
    final diskon = subtotal - transaksi.total;

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      width: 300,
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.black, fontFamily: 'monospace', fontSize: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(child: Text('UMKM PELINDO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            const Center(child: Text('Surabaya')),
            const SizedBox(height: 8),
            Text('Kasir   : ${transaksi.petugas}'),
            Text('Tanggal : ${DateFormat('dd/MM/yy HH:mm').format(transaksi.waktuTransaksi)}'),
            const Text('--------------------------------'),
            // PERBAIKAN: item sekarang adalah KeranjangItem
            ...transaksi.items.map((item) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.barang.namaBarang),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('  ${item.kuantitas} x ${item.barang.harga.toStringAsFixed(0)}'),
                    Text((item.barang.harga * item.kuantitas).toStringAsFixed(0)),
                  ],
                ),
              ],
            )),
            const Text('--------------------------------'),
            _buildTotalRow('Subtotal', subtotal.toStringAsFixed(0)),
            _buildTotalRow('Diskon', diskon.toStringAsFixed(0)),
            const SizedBox(height: 4),
            _buildTotalRow('TOTAL', transaksi.total.toStringAsFixed(0), isBold: true),
            const SizedBox(height: 16),
            const Center(child: Text('--- Terima Kasih ---')),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}