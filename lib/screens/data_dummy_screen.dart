import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/barang.dart';
import '../models/pelanggan.dart';
import '../models/biaya_operasional.dart';
import '../utils/dummy_data_helper.dart';

class DataDummyScreen extends StatefulWidget {
  const DataDummyScreen({super.key});

  @override
  State<DataDummyScreen> createState() => _DataDummyScreenState();
}

class _DataDummyScreenState extends State<DataDummyScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _isiDataDummy() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Sedang mengisi database...';
    });

    try {
      final helper = DummyDataHelper();
      await helper.isiSemuaDataDummy();

      setState(() {
        _isLoading = false;
        _statusMessage = 'Berhasil mengisi database dengan data dummy!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data dummy berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Gagal mengisi data: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _hapusSemuaData() async {
    // Konfirmasi dulu
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus semua data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Menghapus semua data...';
    });

    try {
      final barangBox = Hive.box<Barang>('barangBox');
      final pelangganBox = Hive.box<Pelanggan>('pelangganBox');
      final biayaBox = Hive.box<BiayaOperasional>('biayaBox');

      await barangBox.clear();
      await pelangganBox.clear();
      await biayaBox.clear();

      setState(() {
        _isLoading = false;
        _statusMessage = 'Semua data berhasil dihapus!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Semua data berhasil dihapus!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Gagal menghapus data: $e';
      });
    }
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barangBox = Hive.box<Barang>('barangBox');
    final pelangganBox = Hive.box<Pelanggan>('pelangganBox');
    final biayaBox = Hive.box<BiayaOperasional>('biayaBox');

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Data Dummy'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade700,
                Colors.purple.shade600
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gunakan menu ini untuk mengisi database dengan data dummy untuk testing',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Status Data Saat Ini
              const Text(
                'Status Data Saat Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              _buildStatCard(
                'Barang',
                barangBox.length,
                Icons.inventory_2,
                Colors.blue,
              ),
              const SizedBox(height: 12),

              _buildStatCard(
                'Pelanggan',
                pelangganBox.length,
                Icons.people,
                Colors.green,
              ),
              const SizedBox(height: 12),

              _buildStatCard(
                'Biaya Operasional',
                biayaBox.length,
                Icons.receipt_long,
                Colors.orange,
              ),
              const SizedBox(height: 30),

              // Status Message
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _statusMessage.contains('Berhasil')
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _statusMessage.contains('Berhasil')
                          ? Colors.green.shade200
                          : Colors.orange.shade200,
                    ),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: _statusMessage.contains('Berhasil')
                          ? Colors.green.shade900
                          : Colors.orange.shade900,
                    ),
                  ),
                ),
              if (_statusMessage.isNotEmpty) const SizedBox(height: 20),

              // Tombol Aksi
              if (_isLoading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Mohon tunggu...'),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isiDataDummy,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('ISI DATA DUMMY'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _hapusSemuaData,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('HAPUS SEMUA DATA'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 30),

              // Info Detail
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Dummy yang Akan Ditambahkan:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        '• 12 Barang', 'Produk dengan berbagai kategori'),
                    const SizedBox(height: 8),
                    _buildInfoRow('• 8 Pelanggan', 'Data pelanggan lengkap'),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        '• 10 Biaya Operasional', 'Berbagai kategori biaya'),
                    const SizedBox(height: 8),
                    _buildInfoRow('• 60-150 Transaksi',
                        '30 hari terakhir dengan berbagai metode pembayaran'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
