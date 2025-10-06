import 'package:flutter/material.dart';

class KaryawanScreen extends StatelessWidget {
  const KaryawanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Karyawan')),
      body: const Center(
        child: Text(
          'Fitur Manajemen Karyawan akan dikembangkan di sini.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}