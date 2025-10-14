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
  bool _isLoading = false;
  
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
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _loadBarang() async {
    try {
      final barang = await _barangService.getBarang();
      setState(() {
        _daftarBarang = barang;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memuat data barang: $e', isError: true);
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
              primary: Colors.blue.shade700,
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
              // Header - Mirip dengan RestockScreen
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
                              'Pilih Barang', 
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
                      '${_daftarBarang.length} Produk',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // List barang
              Expanded(
                child: _daftarBarang.isEmpty
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
                              'Tidak ada barang',
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
                        itemCount: _daftarBarang.length,
                        itemBuilder: (context, index) {
                          final barang = _daftarBarang[index];
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
                              border: Border.all(
                                color: _selectedBarang?.id == barang.id
                                    ? Colors.blue.shade400
                                    : Colors.transparent,
                                width: 2,
                              ),
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
                              trailing: _selectedBarang?.id == barang.id
                                  ? Icon(Icons.check_circle, color: Colors.blue.shade700, size: 24)
                                  : const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
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
            ],
          ),
        );
      },
    );
  }

  Future<void> _simpanReturn() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBarang == null) {
      _showSnackBar('Pilih barang terlebih dahulu', isError: true);
      return;
    }

    final jumlah = int.tryParse(_jumlahController.text) ?? 0;
    if (jumlah > _selectedBarang!.stok) {
      _showSnackBar('Jumlah return ($jumlah) melebihi stok tersedia (${_selectedBarang!.stok})', isError: true);
      return;
    }

    if (_selectedAlasan == null) {
      _showSnackBar('Pilih alasan return terlebih dahulu', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Implementasi penyimpanan ke database
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        _showSnackBar('Return berhasil disimpan');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal menyimpan return: $e', isError: true);
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
      _selectedAlasan = null;
      _jumlahController.clear();
      _keteranganController.clear();
    });
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
            child: Row(
              children: [
                // Icon Back
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
                // Teks judul
                const Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Return Barang', 
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
                    // Tanggal Return
                    const Text(
                      'Tanggal Return *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pilihTanggal,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('EEEE, dd MMMM yyyy').format(_tanggalReturn),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey.shade500),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pilih Barang
                    const Text(
                      'Pilih Barang *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showBarangPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _selectedBarang == null
                              ? Row(
                                  children: [
                                    Icon(Icons.inventory_2, color: Colors.blue.shade700, size: 20),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Ketuk untuk memilih barang',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: Colors.grey.shade500),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.inventory_2, color: Colors.blue.shade700, size: 20),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Barang Dipilih:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.grey.shade500, size: 18),
                                          onPressed: _clearSelection,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
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
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStokBadge(_selectedBarang!.stok),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    if (_selectedBarang != null) ...[
                      const SizedBox(height: 24),

                      // Jumlah Return
                      const Text(
                        'Jumlah Return *',
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
                              decoration: InputDecoration(
                                hintText: 'Masukkan jumlah return',
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Jumlah return harus diisi';
                                }
                                final jumlah = int.tryParse(value);
                                if (jumlah == null || jumlah <= 0) {
                                  return 'Masukkan jumlah yang valid';
                                }
                                if (jumlah > _selectedBarang!.stok) {
                                  return 'Jumlah melebihi stok tersedia';
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
                      Text(
                        'Stok tersedia: ${_selectedBarang!.stok} unit',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),

                      // Alasan Return
                      const Text(
                        'Alasan Return *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedAlasan,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                          hint: const Text('Pilih alasan return'),
                          items: _alasanReturn.map((alasan) {
                            return DropdownMenuItem(
                              value: alasan,
                              child: Text(alasan),
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
                          hintText: 'Catatan tambahan untuk return ini...',
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
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedBarang != null ? Container(
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
                onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                onPressed: _isLoading ? null : _simpanReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                        'SIMPAN RETURN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ) : null,
    );
  }
}