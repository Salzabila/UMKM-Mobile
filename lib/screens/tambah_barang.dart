import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/barang.dart';
import '../service/barang_service.dart';
import '../service/foto_service.dart';

class TambahBarangScreen extends StatefulWidget {
  const TambahBarangScreen({super.key});

  @override
  State<TambahBarangScreen> createState() => _TambahBarangScreenState();
}

class _TambahBarangScreenState extends State<TambahBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jenisController = TextEditingController();
  final _stokController = TextEditingController();
  final _hargaController = TextEditingController();
  bool _isLoading = false;
  DateTime? _tanggalExpired;
  File? _fotoFile;

  final _barangService = BarangService();
  final _fotoService = FotoService();

  @override
  void dispose() {
    _namaController.dispose();
    _jenisController.dispose();
    _stokController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> _pilihSumberFoto() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.photo_library, color: Colors.blue.shade600),
              ),
              title: const Text('Pilih dari Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, color: Colors.green.shade600),
              ),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
          ],
        ),
      ),
    );

    if (result == 'gallery') {
      await _pilihDariGallery();
    } else if (result == 'camera') {
      await _ambilDariKamera();
    }
  }

  Future<void> _pilihDariGallery() async {
    final file = await _fotoService.pilihDariGallery();
    if (file != null) {
      setState(() {
        _fotoFile = file;
      });
    }
  }

  Future<void> _ambilDariKamera() async {
    final file = await _fotoService.ambilDariKamera();
    if (file != null) {
      setState(() {
        _fotoFile = file;
      });
    }
  }

  void _hapusFoto() {
    setState(() {
      _fotoFile = null;
    });
  }

  Future<void> _pilihTanggalExpired() async {
    final tanggalTerpilih = await showDatePicker(
      context: context,
      initialDate: _tanggalExpired ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (tanggalTerpilih != null) {
      setState(() {
        _tanggalExpired = tanggalTerpilih;
      });
    }
  }

  Future<void> _simpanProduk() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final barangBaru = Barang(
        id: 'brg-${DateTime.now().millisecondsSinceEpoch}',
        namaBarang: _namaController.text,
        jenis: _jenisController.text,
        tanggalMasuk: DateTime.now(),
        expired: _tanggalExpired,
        stok: int.parse(_stokController.text),
        harga: double.parse(_hargaController.text),
      );

      if (_fotoFile != null) {
        await _barangService.addBarangWithFoto(barangBaru, _fotoFile!);
      } else {
        await _barangService.addBarang(barangBaru);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Produk berhasil ditambahkan!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text('Gagal menyimpan produk: $e'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFotoSection(),
            const SizedBox(height: 16),
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildStokHargaSection(),
            const SizedBox(height: 16),
            _buildExpiredSection(),
            const SizedBox(height: 24),
            _buildSimpanButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Foto Produk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Opsional',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_fotoFile != null)
            _buildFotoPreview()
          else
            _buildTambahFotoButton(),
        ],
      ),
    );
  }

  Widget _buildFotoPreview() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _fotoFile!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pilihSumberFoto,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Ganti'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade600,
                  side: BorderSide(color: Colors.blue.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _hapusFoto,
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Hapus'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTambahFotoButton() {
    return InkWell(
      onTap: _pilihSumberFoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Tambahkan Foto',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap untuk memilih foto',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _namaController,
            label: 'Nama Produk',
            hint: 'Contoh: Aqua 600ml',
            icon: Icons.inventory_2,
            validator: (v) => v!.isEmpty ? 'Nama produk wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _jenisController,
            label: 'Jenis Produk',
            hint: 'Contoh: Minuman',
            icon: Icons.category,
            validator: (v) => v!.isEmpty ? 'Jenis produk wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStokHargaSection() {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stok & Harga',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stokController,
                  label: 'Stok Awal',
                  hint: '0',
                  icon: Icons.inventory,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return 'Wajib diisi';
                    if (int.tryParse(v) == null) return 'Harus angka';
                    if (int.parse(v) < 0) return 'Tidak boleh negatif';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _hargaController,
                  label: 'Harga',
                  hint: '0',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return 'Wajib diisi';
                    if (double.tryParse(v) == null) return 'Harus angka';
                    if (double.parse(v) < 0) return 'Tidak boleh negatif';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildExpiredSection() {
    return Container(
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
          onTap: _pilihTanggalExpired,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.orange.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggal Kedaluwarsa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tanggalExpired == null
                            ? 'Opsional - Tap untuk pilih'
                            : DateFormat('dd MMMM yyyy').format(_tanggalExpired!),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _simpanProduk,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Simpan Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}