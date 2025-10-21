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
  final BarangService _barangService = BarangService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Barang> _daftarBarang = [];
  List<Barang> _filteredBarang = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBarang();
  }

  Future<void> _loadBarang() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      List<Barang> barang = await _barangService.getBarang();
      if (mounted) {
        setState(() {
          _daftarBarang = barang;
          _filteredBarang = barang;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Gagal memuat data: $e', isError: true);
      }
    }
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredBarang = _daftarBarang;
      });
    } else {
      final query = _searchQuery.toLowerCase();
      setState(() {
        _filteredBarang = _daftarBarang.where((b) => 
          b.namaBarang.toLowerCase().contains(query)
        ).toList();
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStokBadge(int stok) {
    Color color;
    String label;
    if (stok <= 5) {
      color = Colors.red;
      label = 'Stok Rendah';
    } else if (stok <= 20) {
      color = Colors.orange;
      label = 'Stok Menengah';
    } else {
      color = Colors.green;
      label = 'Stok Aman';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25), 
        borderRadius: BorderRadius.circular(6)
      ), 
      child: Text(
        label, 
        style: TextStyle(
          color: color, 
          fontSize: 10, 
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  Widget _buildHargaText(double harga) {
    return Text(
      'Rp ${NumberFormat('#,##0', 'id_ID').format(harga)}',
      style: TextStyle(
        fontSize: 14,
        color: Colors.green.shade700,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _showProductActions(Barang barang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 24),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(context), 
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Aksi Produk', 
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white,
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      barang.namaBarang,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Action Buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Informasi Produk
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('Jenis Barang', barang.jenis),
                            const SizedBox(height: 8),
                            _buildInfoRow('Stok', '${barang.stok} unit'),
                            const SizedBox(height: 8),
                            _buildInfoRow('Harga', 'Rp ${NumberFormat('#,##0', 'id_ID').format(barang.harga)}'),
                            const SizedBox(height: 8),
                            _buildInfoRow('Tanggal Masuk', DateFormat('dd/MM/yyyy').format(barang.tanggalMasuk)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Tombol Aksi
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _confirmDelete(barang);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Colors.red.shade400),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete, color: Colors.red.shade400, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'HAPUS',
                                    style: TextStyle(
                                      color: Colors.red.shade400,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // TODO: Navigate to edit screen
                                _showEditFeatureComingSoon();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'EDIT',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditFeatureComingSoon() {
    _showSnackBar('Fitur edit akan segera tersedia');
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(Barang barang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus ${barang.namaBarang}? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _barangService.deleteBarang(barang.id);
                if (mounted) {
                  Navigator.pop(ctx);
                  _loadBarang();
                  _showSnackBar('Produk berhasil dihapus');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(ctx);
                  _showSnackBar('Gagal menghapus produk: $e', isError: true);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header - Sama seperti RestockScreen
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 20,
              left: 16,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20), 
                bottomRight: Radius.circular(20)
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button dan Judul
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context), 
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Manajemen Produk', 
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white,
                          )
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_daftarBarang.length} Produk', 
                          style: const TextStyle(
                            color: Colors.white70, 
                            fontSize: 14,
                          )
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Search Bar
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterProducts();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Daftar Produk
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredBarang.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                            ? 'Belum ada produk' 
                            : 'Produk tidak ditemukan',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600)
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tap tombol + untuk menambah produk',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBarang.length,
                    itemBuilder: (context, index) => _buildProductItem(_filteredBarang[index]),
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
          if (result == true && mounted) {
            _loadBarang();
          }
        },
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  Widget _buildProductItem(Barang barang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2, color: Colors.blue, size: 20),
        ),
        title: Text(
          barang.namaBarang,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Stok: ${barang.stok}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStokBadge(barang.stok),
                ],
              ),
              const SizedBox(height: 4),
              _buildHargaText(barang.harga),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
        onTap: () => _showProductActions(barang),
      ),
    );
  }
}