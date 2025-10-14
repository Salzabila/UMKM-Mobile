import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../models/transaksi.dart';
import '../screens/transaksi_berhasil_screen.dart';

class WidgetStruk extends StatelessWidget {
  final Transaksi transaksi;

  const WidgetStruk({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    // Extract nomor nota untuk barcode (ambil bagian terakhir)
    final nomorNotaParts = transaksi.nomerNota.split('/');
    final barcodeData = nomorNotaParts.isNotEmpty 
        ? nomorNotaParts.last 
        : transaksi.id.substring(3); // Fallback ke ID tanpa prefix TX-

    return Container(
      width: 300,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Toko (sesuai web)
          _buildHeader(),
          const SizedBox(height: 16),
          Container(height: 2, color: Colors.black),
          const SizedBox(height: 16),
          
          // Info Transaksi (format web)
          _buildTransactionInfo(),
          const SizedBox(height: 16),
          
          // Tabel Item (header + content)
          _buildItemTable(),
          const SizedBox(height: 16),
          
          // Total Section
          _buildTotalSection(),
          const SizedBox(height: 16),
          
          // Payment Info
          _buildPaymentInfo(),
          const SizedBox(height: 16),
          
          // Barcode (seperti web)
          _buildBarcode(barcodeData),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.black54),
          const SizedBox(height: 12),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'GERAI UMKM MART',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Jl. Perak Timur No.620, Perak Utara, Kec. Pabean Cantikan,',
          style: TextStyle(
            fontSize: 10,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Surabaya, Jawa Timur 60165',
          style: TextStyle(
            fontSize: 10,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Telp: 0813-3242-1401',
          style: TextStyle(
            fontSize: 10,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionInfo() {
    return Column(
      children: [
        _buildInfoRow('No. Nota', transaksi.nomerNota),
        const SizedBox(height: 6),
        _buildInfoRow(
          'Tanggal',
          DateFormat('dd/MM/yyyy HH:mm').format(transaksi.waktuTransaksi),
        ),
        const SizedBox(height: 6),
        _buildInfoRow('Kasir', transaksi.petugas),
        const SizedBox(height: 6),
        _buildInfoRow('Metode Bayar', transaksi.metodeBayar),
      ],
    );
  }

  Widget _buildItemTable() {
    return Column(
      children: [
        // Header Tabel
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black, width: 1),
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'Item',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  'Qty',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  'Harga',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        
        // Item Rows
        ...transaksi.items.map((item) => _buildItemRow(item)),
      ],
    );
  }

  Widget _buildItemRow(item) {
    final subtotal = item.barang.harga * item.kuantitas;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black26, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              item.barang.namaBarang,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${item.kuantitas}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              NumberFormat('#,##0', 'id_ID').format(item.barang.harga),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              NumberFormat('#,##0', 'id_ID').format(subtotal),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Rp ${NumberFormat('#,##0', 'id_ID').format(transaksi.total)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bayar',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              'Rp ${NumberFormat('#,##0', 'id_ID').format(transaksi.uangDiterima)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kembalian',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              'Rp ${NumberFormat('#,##0', 'id_ID').format(transaksi.kembalian)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarcode(String data) {
    return Column(
      children: [
        // Barcode
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(4),
          ),
          child: BarcodeWidget(
            barcode: Barcode.code128(),
            data: data,
            width: 200,
            height: 60,
            drawText: false,
          ),
        ),
        const SizedBox(height: 8),
        // Nomor di bawah barcode
        Text(
          data,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          '*** TERIMA KASIH ***',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Barang yang sudah dibeli tidak dapat dikembalikan.',
          style: TextStyle(
            fontSize: 9,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          DateFormat('dd/MM/yyyy HH:mm:ss').format(transaksi.waktuTransaksi),
          style: const TextStyle(
            fontSize: 8,
            color: Colors.black38,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label :',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}