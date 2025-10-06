import 'package:flutter/material.dart';
import '../service/notifikasi.dart';
import '../service/barang_service.dart';

class NotifikasiExpiredScreen extends StatefulWidget {
  final List<NotifikasiProduk> daftarNotifikasi;
  const NotifikasiExpiredScreen({super.key, required this.daftarNotifikasi});

  @override
  State<NotifikasiExpiredScreen> createState() => _NotifikasiExpiredScreenState();
}

class _NotifikasiExpiredScreenState extends State<NotifikasiExpiredScreen> {
  late List<NotifikasiProduk> _notifikasi;
  final BarangService _barangService = BarangService();
  bool _adaPerubahan = false;

  @override
  void initState() {
    super.initState();
    _notifikasi = List.from(widget.daftarNotifikasi);
  }

  Future<void> _hapusProduk(String produkId, int index) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: const Text('Anda yakin ingin menghapus produk ini secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      try {
        await _barangService.deleteBarang(produkId);
        setState(() {
          _notifikasi.removeAt(index);
          _adaPerubahan = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil dihapus.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus produk: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  String _getStatusText(NotifikasiProduk notifikasi) {
    if (notifikasi.hariMenujuExpired < 0) {
      return 'Sudah kedaluwarsa ${notifikasi.hariMenujuExpired.abs()} hari yang lalu';
    } else if (notifikasi.hariMenujuExpired == 0) {
      return 'Kedaluwarsa hari ini';
    } else {
      return 'Akan kedaluwarsa dalam ${notifikasi.hariMenujuExpired} hari';
    }
  }

  Color _getStatusColor(NotifikasiProduk notifikasi) {
    if (notifikasi.hariMenujuExpired < 0) {
      return Colors.red;
    } else if (notifikasi.hariMenujuExpired <= 3) {
      return Colors.orange;
    } else {
      return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produk Kedaluwarsa (${_notifikasi.length})'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(_adaPerubahan);
          },
        ),
      ),
      body: _notifikasi.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
                  SizedBox(height: 16),
                  Text('Semua produk aman!', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _notifikasi.length,
              itemBuilder: (context, index) {
                final notifikasi = _notifikasi[index];
                final statusColor = _getStatusColor(notifikasi);
                
                // PERBAIKAN: Ganti "return null;" dengan widget yang proper
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor,
                      child: Icon(
                        notifikasi.hariMenujuExpired < 0 
                            ? Icons.dangerous 
                            : Icons.warning,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notifikasi.barang.namaBarang,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(notifikasi),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (notifikasi.barang.stok > 0)
                          Text('Stok: ${notifikasi.barang.stok} unit'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String choice) {
                        if (choice == 'hapus') {
                          // PENGGUNAAN function _hapusProduk di sini
                          _hapusProduk(notifikasi.barang.id, index);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<String>(
                            value: 'hapus',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Hapus Produk', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                    isThreeLine: true, // Ubah ke boolean langsung karena selalu menampilkan subtitle
                  ),
                );
              },
            ),
    );
  }
}