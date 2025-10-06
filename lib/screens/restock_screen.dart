import 'package:flutter/material.dart';
import '../models/barang.dart';
import '../service/barang_service.dart';

class RestockScreen extends StatefulWidget {
  const RestockScreen({super.key});

  @override
  State<RestockScreen> createState() => _RestockScreenState();
}

class _RestockScreenState extends State<RestockScreen> {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showRestockForm(Barang barang) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (_) => RestockFormScreen(
          barang: barang, 
          onRestockComplete: _loadBarang
        )
      )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24), 
                      onPressed: () => Navigator.pop(context), 
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kelola Stok', 
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white
                          )
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_daftarBarang.length} Produk', 
                          style: const TextStyle(
                            color: Colors.white70, 
                            fontSize: 14
                          )
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Search Bar - Diperbaiki
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
                        fontSize: 16, // Ukuran font diperbesar
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
                            ? 'Tidak ada produk' 
                            : 'Produk tidak ditemukan',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600)
                        ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          padding: const EdgeInsets.only(top: 4),
          child: Row(
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
        ),
        onTap: () => _showRestockForm(barang),
      ),
    );
  }
}

class RestockFormScreen extends StatefulWidget {
  final Barang barang;
  final VoidCallback onRestockComplete;

  const RestockFormScreen({super.key, required this.barang, required this.onRestockComplete});

  @override
  State<RestockFormScreen> createState() => _RestockFormScreenState();
}

class _RestockFormScreenState extends State<RestockFormScreen> {
  final BarangService _barangService = BarangService();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int get _stokTambahan => int.tryParse(_jumlahController.text) ?? 0;
  int get _totalStokBaru => widget.barang.stok + _stokTambahan;

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _submitRestock() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _barangService.updateStokBarang(widget.barang, _stokTambahan);
        if (mounted) {
          widget.onRestockComplete();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Stok berhasil ditambahkan!'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambah stok: $e'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 24, left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20), 
                bottomRight: Radius.circular(20)
              )
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24), 
                  onPressed: () => Navigator.pop(context), 
                ),
                const SizedBox(width: 12),
                const Text(
                  'Form Restock Barang', 
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  )
                ),
              ],
            ),
          ),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Barang
                    const Text(
                      'Informasi Barang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Nama Barang', widget.barang.namaBarang),
                          const SizedBox(height: 8),
                          _buildInfoRow('Stok Saat Ini', '${widget.barang.stok} unit'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Supplier', 'UMKM JAYA'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Harga Jual', 'Rp ${widget.barang.harga}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Jumlah Stok Tambahan - Diperbaiki
                    const Text(
                      'Jumlah Stok Tambahan *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _jumlahController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) => setState(() {}),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white, // Warna background putih
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade400), // Border yang terlihat
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.blue.shade700),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah stok harus diisi';
                              }
                              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                return 'Masukkan jumlah yang valid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'unit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'Minimal 1 unit untuk menambah stok', 
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Keterangan
                    const Text(
                      'Keterangan (Opsional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _keteranganController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Catatan tambahan untuk restock ini...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Perhitungan Stok
                    if (_stokTambahan > 0)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Perhitungan Stok',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildCalculationRow('Stok Lama', '${widget.barang.stok} unit'),
                            const SizedBox(height: 8),
                            _buildCalculationRow('Stok Tambahan', '$_stokTambahan unit'),
                            const Divider(height: 20),
                            _buildCalculationRow('Total Stok Baru', '$_totalStokBaru unit', isTotal: true),
                          ],
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _submitRestock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'TAMBAH STOK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildCalculationRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
  }
}