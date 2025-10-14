
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/pelanggan.dart';
import '../service/keranjang_provider.dart';
import 'pembayaran_screen.dart'; // PERBAIKAN: Ubah dari ./pembayaran.dart
import './pelanggan_list_screen.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  // MODERN COLOR PALETTE - Consistent with Dashboard
  static const Color _primaryColor = Color(0xFF6366F1);
  static const Color _accentColor = Color(0xFF06D6A0);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _infoColor = Color(0xFF3B82F6);
  
  static const Color _bgColor = Color(0xFFFAFAFA);
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _textTertiary = Color(0xFF9CA3AF);
  static const Color _borderColor = Color(0xFFE5E7EB);

  static final BoxShadow _softShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 16,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );

  static final BoxShadow _floatingShadow = BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 32,
    offset: const Offset(0, 12),
    spreadRadius: -8,
  );

  void _bukaDaftarPelanggan() async {
    final pelangganTerpilih = await Navigator.of(context).push<Pelanggan>(
      MaterialPageRoute(
        builder: (_) => const PelangganListScreen(),
      ),
    );
    if (pelangganTerpilih != null && mounted) {
      Provider.of<KeranjangProvider>(context, listen: false).pilihPelanggan(pelangganTerpilih);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KeranjangProvider>(
      builder: (ctx, keranjang, child) {
        return Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            title: const Text(
              'Keranjang Belanja',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            backgroundColor: _surfaceColor,
            foregroundColor: _textPrimary,
            elevation: 0,
            centerTitle: false,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: _borderColor),
            ),
            actions: [
              if (keranjang.items.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart_rounded, 
                          color: _primaryColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${keranjang.items.length}',
                        style: const TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Modern Customer Section
              _buildModernPelangganSection(keranjang),
              const SizedBox(height: 20),

              // Modern Items Section
              _buildModernItemsSection(keranjang),
              
              if (keranjang.items.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildModernTambahProdukButton(),
                const SizedBox(height: 20),
                _buildModernMetodePembayaran(keranjang),
                const SizedBox(height: 100),
              ]
            ],
          ),
          bottomNavigationBar: _buildModernBottomSummary(keranjang),
        );
      },
    );
  }

  Widget _buildModernPelangganSection(KeranjangProvider keranjang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_softShadow],
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: InkWell(
        onTap: _bukaDaftarPelanggan,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: keranjang.pelanggan != null 
                    ? _successColor.withOpacity(0.1)
                    : _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                keranjang.pelanggan != null 
                    ? Icons.person_rounded
                    : Icons.person_add_alt_1_rounded,
                color: keranjang.pelanggan != null 
                    ? _successColor
                    : _primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Pelanggan',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    keranjang.pelanggan?.namaLengkap ?? 'Pilih Pelanggan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: keranjang.pelanggan != null 
                          ? _textPrimary 
                          : _textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (keranjang.pelanggan != null)
              IconButton(
                onPressed: () => keranjang.hapusPelanggan(),
                icon: const Icon(Icons.close_rounded, size: 20, color: _textTertiary),
                style: IconButton.styleFrom(
                  backgroundColor: _bgColor,
                  minimumSize: const Size(40, 40),
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: _textTertiary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildModernItemsSection(KeranjangProvider keranjang) {
    if (keranjang.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [_softShadow],
          border: Border.all(color: _borderColor, width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 40,
                color: _textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keranjang Kosong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan tambahkan produk ke keranjang',
              style: TextStyle(
                fontSize: 14,
                color: _textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
              label: const Text('Pilih Produk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_softShadow],
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, 
                      color: _primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Item di Keranjang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${keranjang.items.length} item',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...keranjang.items.values.map((item) => Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: _primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.barang.namaBarang,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Rp ${NumberFormat('#,##0', 'id_ID').format(item.barang.harga)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _borderColor),
                    boxShadow: [_softShadow],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => keranjang.kurangiKuantitas(item.barang.id),
                        icon: const Icon(Icons.remove_rounded, size: 18, color: _textSecondary),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(36, 36),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 24),
                        child: Text(
                          '${item.kuantitas}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => keranjang.tambahProduk(item.barang),
                        icon: const Icon(Icons.add_rounded, size: 18, color: _primaryColor),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(36, 36),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildModernTambahProdukButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
        boxShadow: [_softShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, 
                    color: _primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tambah Produk Lain',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernMetodePembayaran(KeranjangProvider keranjang) {
    final List<Map<String, dynamic>> metodeList = [
      {'nama': 'Tunai', 'icon': Icons.money_rounded, 'color': _successColor},
      {'nama': 'QRIS', 'icon': Icons.qr_code_2_rounded, 'color': _primaryColor},
      {'nama': 'Transfer', 'icon': Icons.swap_horiz_rounded, 'color': _infoColor},
      {'nama': 'Debit', 'icon': Icons.credit_card_rounded, 'color': _accentColor},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_softShadow],
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payment_rounded, 
                    color: _successColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...metodeList.map((metode) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: keranjang.metodePembayaran == metode['nama']
                  ? metode['color'].withOpacity(0.1)
                  : _bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: keranjang.metodePembayaran == metode['nama']
                    ? metode['color']
                    : _borderColor,
                width: keranjang.metodePembayaran == metode['nama'] ? 2 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: metode['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  metode['icon'],
                  color: metode['color'],
                  size: 24,
                ),
              ),
              title: Text(
                metode['nama'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: keranjang.metodePembayaran == metode['nama']
                      ? metode['color']
                      : _textPrimary,
                  fontSize: 16,
                ),
              ),
              trailing: keranjang.metodePembayaran == metode['nama']
                  ? Icon(Icons.check_circle_rounded, color: metode['color'], size: 24)
                  : const Icon(Icons.circle_outlined, color: _textTertiary, size: 24),
              onTap: () {
                keranjang.pilihMetodePembayaran(metode['nama']);
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildModernBottomSummary(KeranjangProvider keranjang) {
    if (keranjang.items.isEmpty) return const SizedBox.shrink();
    
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [_floatingShadow],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Tagihan',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  'Rp ${NumberFormat('#,##0', 'id_ID').format(keranjang.totalHarga)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PembayaranScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_rounded, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Lanjutkan Pembayaran',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}