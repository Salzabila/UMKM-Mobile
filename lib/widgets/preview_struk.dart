import 'package:flutter/material.dart';
import '../service/keranjang_provider.dart';

class PreviewStruk extends StatelessWidget {
  final KeranjangProvider keranjang;
  const PreviewStruk({super.key, required this.keranjang});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('Kasir: SalSalsabila', style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 24),
          ...keranjang.items.values.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.kuantitas}x ${item.barang.namaBarang}'),
                  Text('Rp ${(item.barang.harga * item.kuantitas).toStringAsFixed(0)}'),
                ],
              ),
            );
          }),
          const Divider(height: 32),
          _buildTotalRow('Total QYT', '${keranjang.jumlahItem}'),
          const SizedBox(height: 8),
          _buildTotalRow('Subtotal', 'Rp ${keranjang.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildTotalRow('Total Diskon', '(Rp ${keranjang.diskon.toStringAsFixed(0)})'),
          const Divider(height: 24),
          _buildTotalRow('Total', 'Rp ${keranjang.totalHarga.toStringAsFixed(0)}', isBold: true),
        ],
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