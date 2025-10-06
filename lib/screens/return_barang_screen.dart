import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/barang.dart';
import '../service/barang_service.dart';

class ReturnBarangScreen extends StatefulWidget {
  const ReturnBarangScreen({super.key});

  @override
  State<ReturnBarangScreen> createState() => _ReturnBarangScreenState();
}

class _ReturnBarangScreenState extends State<ReturnBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  final BarangService _barangService = BarangService();
  
  DateTime _tanggalReturn = DateTime.now();
  Barang? _selectedBarang;
  String? _selectedAlasan;
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  
  List<Barang> _daftarBarang = [];
  List<Barang> _filteredBarang = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _alasanReturn = [
    'Rusak',
    'Cacat',
    'Kadaluarsa',
    'Salah Kirim',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadBarang();
    _searchController.addListener(_filterBarang);
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterBarang() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBarang = _daftarBarang.where((barang) {
        return barang.namaBarang.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadBarang() async {
    try {
      final barang = await _barangService.getBarang();
      setState(() {
        _daftarBarang = barang;
        _filteredBarang = barang;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data barang: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalReturn,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _tanggalReturn) {
      setState(() {
        _tanggalReturn = picked;
      });
    }
  }

  // Fungsi untuk menentukan status stok
  Widget _buildStatusStok(int stok) {
    if (stok > 20) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Text(
          'Stok Aman',
          style: TextStyle(
            color: Colors.green.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else if (stok >= 10) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Text(
          'Stok Menengah',
          style: TextStyle(
            color: Colors.orange.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          'Stok Rendah',
          style: TextStyle(
            color: Colors.red.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }

  void _showBarangPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header seperti di gambar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul dan jumlah produk
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Barang',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_filteredBarang.length} Produk',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Search bar seperti di gambar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // List barang
              Expanded(
                child: _filteredBarang.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Tidak ada barang'
                                  : 'Barang tidak ditemukan',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredBarang.length,
                        itemBuilder: (context, index) {
                          final barang = _filteredBarang[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedBarang?.id == barang.id
                                    ? Colors.blue.shade400
                                    : Colors.grey.shade200,
                                width: _selectedBarang?.id == barang.id ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: Colors.blue.shade600,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                barang.namaBarang,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stok: ${barang.stok}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildStatusStok(barang.stok),
                                ],
                              ),
                              trailing: _selectedBarang?.id == barang.id
                                  ? Icon(Icons.check_circle, color: Colors.blue.shade600, size: 24)
                                  : const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
                              onTap: () {
                                setState(() {
                                  _selectedBarang = barang;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
              
              // Footer dengan selected item
              if (_selectedBarang != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border(
                      top: BorderSide(color: Colors.blue.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Terpilih: ${_selectedBarang!.namaBarang}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearSelection,
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _simpanReturn() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBarang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih barang terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final jumlah = int.tryParse(_jumlahController.text) ?? 0;
    if (jumlah > _selectedBarang!.stok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jumlah return ($jumlah) melebihi stok tersedia (${_selectedBarang!.stok})'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Implementasi penyimpanan ke database
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Return berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan return: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedBarang = null;
      _searchController.clear();
      _filterBarang();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Return Barang'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildDateField(),
            const SizedBox(height: 20),
            _buildBarangField(),
            if (_selectedBarang != null) ...[
              const SizedBox(height: 20),
              _buildJumlahField(),
              const SizedBox(height: 20),
              _buildAlasanField(),
              const SizedBox(height: 20),
              _buildKeteranganField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Tanggal Return', Icons.calendar_today),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pilihTanggal,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(_tanggalReturn),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarangField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Pilih Barang', Icons.inventory_2),
        const SizedBox(height: 8),
        
        // Field utama untuk memilih barang
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showBarangPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _selectedBarang == null
                          ? Text(
                              'Cari produk...',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedBarang!.namaBarang,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Stok: ${_selectedBarang!.stok}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatusStok(_selectedBarang!.stok),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    if (_selectedBarang != null)
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade500, size: 20),
                        onPressed: _clearSelection,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade500, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Pesan info
        if (_selectedBarang == null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade700,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pilih barang terlebih dahulu',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildJumlahField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Jumlah Return', Icons.format_list_numbered),
        const SizedBox(height: 8),
        TextFormField(
          controller: _jumlahController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Masukkan jumlah return...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
            suffixIcon: _selectedBarang != null
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'dari ${_selectedBarang!.stok}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jumlah return wajib diisi';
            }
            final jumlah = int.tryParse(value);
            if (jumlah == null || jumlah <= 0) {
              return 'Jumlah harus angka dan lebih dari 0';
            }
            if (_selectedBarang != null && jumlah > _selectedBarang!.stok) {
              return 'Jumlah melebihi stok tersedia (${_selectedBarang!.stok})';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAlasanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Alasan Return', Icons.warning_amber),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedAlasan,
            decoration: InputDecoration(
              hintText: '-- Pilih Alasan Return --',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 24),
            items: _alasanReturn.map((alasan) {
              return DropdownMenuItem(
                value: alasan,
                child: Text(
                  alasan,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAlasan = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Pilih alasan return terlebih dahulu';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKeteranganField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Keterangan (Opsional)', Icons.note_alt, required: false),
        const SizedBox(height: 8),
        TextFormField(
          controller: _keteranganController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tambahkan keterangan tambahan...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _simpanReturn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Simpan Return',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon, {bool required = true}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
        ],
      ],
    );
  }
}