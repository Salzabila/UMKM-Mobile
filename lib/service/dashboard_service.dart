import 'dart:math';
import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../models/transaksi.dart';

class DashboardService {
  Future<DashboardData> fetchDashboardData(DateTimeRange dateRange) async {
    // Simulasi jeda jaringan
    await Future.delayed(const Duration(milliseconds: 800));

    // --- Logika untuk menghasilkan data palsu yang dinamis ---
    final random = Random();
    final int durationInDays = dateRange.duration.inDays.clamp(1, 365);
    final double multiplier = durationInDays.toDouble();

    // =======================================================================
    // PERBAIKAN: Menambahkan parameter 'petugas' dan 'status' yang wajib
    // =======================================================================
    final dummyAktivitas = List.generate(
      5, // Selalu tampilkan 5 aktivitas terbaru
      (index) => Transaksi(
        id: 'T${random.nextInt(1000)}',
        nomerNota: 'NT-00${random.nextInt(100)}',
        waktuTransaksi: dateRange.start.add(
          Duration(seconds: random.nextInt(dateRange.duration.inSeconds.clamp(1, 999999))),
        ),
        petugas: 'Kasir 1', // PARAMETER WAJIB DITAMBAHKAN
        status: 'Sukses',   // PARAMETER WAJIB DITAMBAHKAN
        metodeBayar: index.isEven ? 'Tunai' : 'QRIS',
        total: 50000 + (random.nextDouble() * 150000), // Total acak
        items: [], // Biarkan kosong untuk data palsu
      ),
    )..sort((a, b) => b.waktuTransaksi.compareTo(a.waktuTransaksi)); // Urutkan dari yang terbaru

    final dummyGrafik = List.generate(7, (index) => random.nextDouble() * 800 + 100);

    return DashboardData(
      pendapatan: (random.nextDouble() * 500000 + 200000) * multiplier,
      transaksiSukses: (random.nextInt(10) + 5) * multiplier.toInt(),
      barangKeluar: (random.nextInt(50) + 20) * multiplier.toInt(),
      biayaOperasional: (random.nextDouble() * 100000 + 50000) * multiplier,
      aktivitasTerbaru: dummyAktivitas,
      dataGrafikPendapatan: dummyGrafik,
    );
  }
}