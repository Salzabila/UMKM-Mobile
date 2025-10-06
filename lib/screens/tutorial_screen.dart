import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tutorial Penggunaan")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text("Apa yang kamu butuhkan untuk menggunakan aplikasi ini?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text("1. Akun login yang valid (kasir/admin)."),
          Text("2. Koneksi internet stabil."),
          Text("3. Data barang dan pelanggan sudah dimasukkan."),
          SizedBox(height: 20),
          Text("Langkah awal penggunaan:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("- Login dengan akun kamu."),
          Text("- Tambahkan barang di menu manajemen."),
          Text("- Lakukan transaksi di menu keranjang."),
          Text("- Cek laporan di menu analisis & rekap."),
        ],
      ),
    );
  }
}