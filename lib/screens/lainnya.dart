import 'package:flutter/material.dart';
import 'restock_screen.dart';
import 'return_barang_screen.dart';
import 'operasional_screen.dart';
import './rekapitulasi.dart';

class LainnyaScreen extends StatelessWidget {
  const LainnyaScreen({super.key});

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

  static final BoxShadow _mediumShadow = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 24,
    offset: const Offset(0, 8),
    spreadRadius: -4,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          'Menu Lainnya',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),
            const SizedBox(height: 32),
            
            // Menu Items Grid
            Expanded(
              child: _buildMenuGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_softShadow],
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryColor, _infoColor],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.more_horiz_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fitur Tambahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Akses menu manajemen dan laporan toko',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final List<MenuCard> menuItems = [
      MenuCard(
        title: 'Restock Barang',
        subtitle: 'Catat penambahan stok produk',
        icon: Icons.inventory_2_rounded,
        color: _successColor,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RestockScreen())
        ),
      ),
      MenuCard(
        title: 'Return Barang',
        subtitle: 'Catat pengembalian barang rusak/kedaluwarsa',
        icon: Icons.assignment_return_rounded,
        color: _warningColor,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReturnBarangScreen())
        ),
      ),
      MenuCard(
        title: 'Biaya Operasional',
        subtitle: 'Catat semua pengeluaran toko',
        icon: Icons.receipt_long_rounded,
        color: _infoColor,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OperasionalScreen())
        ),
      ),
      MenuCard(
        title: 'Rekapitulasi',
        subtitle: 'Lihat laporan penjualan dan keuangan',
        icon: Icons.assessment_rounded,
        color: _primaryColor,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RekapitulasiScreen())
        ),
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) => _buildModernMenuCard(menuItems[index]),
    );
  }

  Widget _buildModernMenuCard(MenuCard menu) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: menu.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [_softShadow],
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: menu.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    menu.icon,
                    color: menu.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  menu.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  menu.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                
                // Arrow Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: menu.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: menu.color,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}