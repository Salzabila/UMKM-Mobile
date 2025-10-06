import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/barang.dart';
import '../service/barang_service.dart';
import './tambah_barang.dart';

class ManajemenBarangScreen extends StatefulWidget {
  const ManajemenBarangScreen({super.key});

  @override
  State<ManajemenBarangScreen> createState() => _ManajemenBarangScreenState();
}

class _ManajemenBarangScreenState extends State<ManajemenBarangScreen> {
  late Future<List<Barang>> _barangFuture;
  final BarangService _barangService = BarangService();
  final TextEditingController _searchController = TextEditingController();
  List<Barang> _filteredBarang = [];

  @override
  void initState() {
    super.initState();
    _muatUlangProduk();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _muatUlangProduk() {
    setState(() {
      _barangFuture = _barangService.getBarang();
    });
  }

  void _onSearchChanged() {
    _barangFuture.then((barangList) {
      setState(() {
        if (_searchController.text.isEmpty) {
          _filteredBarang = barangList;
        } else {
          _filteredBarang = barangList.where((barang) =>
            barang.namaBarang.toLowerCase().contains(_searchController.text.toLowerCase())
          ).toList();
        }
      });
    });
  }

  Color _getStockIndicatorColor(int stock) {
    if (stock == 0) return Colors.red.shade400;
    if (stock <= 5) return Colors.orange.shade400;
    return Colors.green.shade400;
  }

  IconData _getCategoryIcon(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'minuman':
        return Icons.local_drink;
      case 'makanan':
        return Icons.restaurant;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _muatUlangProduk,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            color: Colors.blue.shade600,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Product List
          Expanded(
            child: FutureBuilder<List<Barang>>(
              future: _barangFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _muatUlangProduk,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada produk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap tombol + untuk menambah produk',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                final daftarBarang = snapshot.data!;
                if (_filteredBarang.isEmpty && _searchController.text.isEmpty) {
                  _filteredBarang = daftarBarang;
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredBarang.length,
                  itemBuilder: (context, index) {
                    final barang = _filteredBarang[index];
                    return _buildProductCard(barang);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => const TambahBarangScreen(),
            ),
          );
          if (result == true) _muatUlangProduk();
        },
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProductCard(Barang barang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navigate to edit screen
            _showProductDetail(barang);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon with background (Profile style)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStockIndicatorColor(barang.stok).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(barang.jenis),
                    color: _getStockIndicatorColor(barang.stok),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang.namaBarang,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Stok: ${barang.stok}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Rp ${NumberFormat('#,##0', 'id_ID').format(barang.harga)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon (Profile style)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetail(Barang barang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                barang.namaBarang,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Details
              _buildDetailRow('Jenis', barang.jenis),
              _buildDetailRow('Stok', '${barang.stok} unit'),
              _buildDetailRow('Harga', 'Rp ${NumberFormat('#,##0', 'id_ID').format(barang.harga)}'),
              _buildDetailRow('Tanggal Masuk', DateFormat('dd/MM/yyyy').format(barang.tanggalMasuk)),
              if (barang.expired != null)
                _buildDetailRow('Expired', DateFormat('dd/MM/yyyy').format(barang.expired!)),
              
              const SizedBox(height: 24),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(barang);
                      },
                      icon: const Icon(Icons.delete, size: 20),
                      label: const Text('Hapus'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Navigate to edit screen
                      },
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Barang barang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus ${barang.namaBarang}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _barangService.deleteBarang(barang.id);
              if (mounted) {
                Navigator.pop(ctx);
                _muatUlangProduk();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produk berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}