import 'package:flutter/material.dart';
import 'package:aplikasi_umkm/screens/dashboard.dart';
import 'package:aplikasi_umkm/screens/transaksi.dart';
import 'package:aplikasi_umkm/screens/riwayat_ikon.dart';
import 'package:aplikasi_umkm/screens/analisis.dart'; 
import 'package:aplikasi_umkm/screens/profil_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // WARNA BIRU UNTUK HIGHLIGHT
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _blueLight = Color(0xFF42A5F5);
  static const Color _blueDark = Color(0xFF0D47A1);
  static const Color _blueBackground = Color(0x1A1976D2);
  static const Color _textGray = Color(0xFF757575);
  static const Color _textDark = Color(0xFF212121);

  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(), // Index 0: Home
    const TransaksiScreen(),  // Index 1: Kasir
    const RiwayatScreen(),   // Index 2: Riwayat
    const AnalisisScreen(),  // Index 3: Analisis Keuangan 
    const ProfilScreen(),   // Index 4: Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Home
                    _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                      isSelected: _selectedIndex == 0,
                    ),
                    
                    // Riwayat
                    _buildNavItem(
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long_rounded,
                      label: 'Riwayat',
                      index: 2,
                      isSelected: _selectedIndex == 2,
                    ),
                    
                    // Kasir (Center - Bigger)
                    _buildCenterNavItem(),
                    
                    // Analisis
                    _buildNavItem(
                      icon: Icons.analytics_outlined,
                      activeIcon: Icons.analytics_rounded,
                      label: 'Analisis',
                      index: 3,
                      isSelected: _selectedIndex == 3,
                    ),
                    
                    // Profil
                    _buildNavItem(
                      icon: Icons.person_outlined,
                      activeIcon: Icons.person_rounded,
                      label: 'Profil',
                      index: 4,
                      isSelected: _selectedIndex == 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? _blueBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: _primaryBlue.withOpacity(0.2), width: 1) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                size: 20,
                color: isSelected ? _primaryBlue : _textGray,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? _primaryBlue : _textGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem() {
    final bool isSelected = _selectedIndex == 1;
    return GestureDetector(
      onTap: () => _onItemTapped(1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced circular container with blue gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 44 : 42,
            height: isSelected ? 44 : 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected 
                  ? [_blueDark, _primaryBlue] // Gradient biru saat aktif
                  : [_primaryBlue, _blueLight], // Gradient biru saat tidak aktif
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(isSelected ? 0.4 : 0.3),
                  blurRadius: isSelected ? 8 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.05 : 1.0,
              child: const Icon(
                Icons.point_of_sale_outlined,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? _primaryBlue : _primaryBlue,
              fontWeight: FontWeight.w600,
            ),
            child: const Text('Kasir'),
          ),
        ],
      ),
    );
  }
}