import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/dashboard_data.dart';
import '../models/transaksi.dart';
import '../service/dashboard_service.dart';
import '../service/notifikasi.dart';
import '../service/transaksi_service.dart';
import '../utils/enums.dart';
import '../utils/filter_result.dart';
import 'manajemen_barang.dart';
import 'notifikasi_expired.dart';
import 'operasional.dart';
import 'pelanggan_list_screen.dart';
import 'rekapitulasi.dart';
import 'restock_screen.dart';
import 'return_barang_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final DashboardService _dashboardService = DashboardService();
  final TransaksiService _transaksiService = TransaksiService();
  final NotifikasiService _notifikasiService = NotifikasiService();
  
  Future<DashboardData>? _dashboardDataFuture;
  Future<List<Transaksi>>? _recentTransactionsFuture;
  
  late FilterResult _currentFilter;
  List<NotifikasiProduk>? _daftarNotifikasi;
  
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  
  // HAPUS: Timer? _refreshTimer; - tidak perlu auto-refresh
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentFilter = FilterResult(
      periode: PeriodeWaktu.hariIni,
      dateRange: DateTimeRange(start: DateTime(now.year, now.month, now.day), end: now),
    );
    
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _loadData();
    _cekExpired();
    
    _headerAnimationController.forward();
    _contentAnimationController.forward();
    
    // HAPUS auto-refresh timer - update manual via user action saja
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    // HAPUS timer cancel karena tidak ada timer
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _dashboardDataFuture = _dashboardService.fetchDashboardData(_currentFilter.dateRange);
      _recentTransactionsFuture = _transaksiService.getRiwayatTransaksi();
      _lastUpdateTime = DateTime.now();
    });
  }

  Future<void> _cekExpired() async {
    final notifikasi = await _notifikasiService.cekProdukKedaluwarsa(batasHari: 30);
    if (mounted) {
      setState(() {
        _daftarNotifikasi = notifikasi.isNotEmpty ? notifikasi : null;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
    await _cekExpired();
    _contentAnimationController.forward(from: 0);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang"; 
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  String _getPeriodeText() {
    switch (_currentFilter.periode) {
      case PeriodeWaktu.hariIni:
        return 'Hari Ini';
      case PeriodeWaktu.mingguIni:
        return 'Minggu Ini';
      case PeriodeWaktu.bulanIni:
        return 'Bulan Ini';
      case PeriodeWaktu.tahunIni:
        return 'Tahun Ini';
      case PeriodeWaktu.custom:
        final start = DateFormat('dd MMM').format(_currentFilter.dateRange.start);
        final end = DateFormat('dd MMM yyyy').format(_currentFilter.dateRange.end);
        return '$start - $end';
    }
  }

  DateTimeRange _getDateRangeForPeriode(PeriodeWaktu periode) {
    final now = DateTime.now();
    switch (periode) {
      case PeriodeWaktu.hariIni:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      case PeriodeWaktu.mingguIni:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: now,
        );
      case PeriodeWaktu.bulanIni:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case PeriodeWaktu.tahunIni:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
      case PeriodeWaktu.custom:
        return _currentFilter.dateRange;
    }
  }

  DashboardData _getDefaultDashboardData() {
    return DashboardData(
      pendapatan: 0,
      transaksiSukses: 0,
      barangKeluar: 0,
      biayaOperasional: 0,
      dataGrafikPendapatan: const [],
      aktivitasTerbaru: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildModernHeader()),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPeriodeFilter(),
                    const SizedBox(height: 16),
                    if (_daftarNotifikasi != null) ...[
                      _buildWarningBanner(),
                      const SizedBox(height: 16),
                    ],
                    _buildStatsCards(),
                    const SizedBox(height: 16),
                    _buildFinancialSummary(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return FadeTransition(
      opacity: _headerAnimationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _headerAnimationController,
          curve: Curves.easeOut,
        )),
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade700,
                Colors.purple.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Kasir 1",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('HH:mm').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getPeriodeText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodeFilter() {
    final filters = [
      ('Hari Ini', PeriodeWaktu.hariIni),
      ('Minggu Ini', PeriodeWaktu.mingguIni),
      ('Bulan Ini', PeriodeWaktu.bulanIni),
      ('Tahun Ini', PeriodeWaktu.tahunIni),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _currentFilter.periode == filter.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Colors.blue.shade500, Colors.blue.shade600],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _currentFilter = FilterResult(
                        periode: filter.$2,
                        dateRange: _getDateRangeForPeriode(filter.$2),
                      );
                    });
                    _loadData();
                    _contentAnimationController.forward(from: 0);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Text(
                      filter.$1,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWarningBanner() {
    if (_daftarNotifikasi == null) return const SizedBox.shrink();
    
    final jumlahProduk = _daftarNotifikasi!.length;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.red.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotifikasiExpiredScreen(daftarNotifikasi: _daftarNotifikasi!),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$jumlahProduk Produk Perlu Perhatian',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Mendekati tanggal kedaluwarsa",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return FutureBuilder<DashboardData>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? _getDefaultDashboardData();
        
        return Column(
          children: [
            // Real-time indicator - update berdasarkan action user
            if (!isLoading && _lastUpdateTime != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Terakhir diperbarui ${DateFormat('HH:mm:ss').format(_lastUpdateTime!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Transaksi',
                    value: data.transaksiSukses.toString(),
                    icon: Icons.receipt_long_rounded,
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Produk Terjual',
                    value: data.barangKeluar.toString(),
                    icon: Icons.shopping_basket_rounded,
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> colors,
    bool isLoading = false,
  }) {
    return FadeTransition(
      opacity: _contentAnimationController,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                value,
                key: ValueKey(value),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return FutureBuilder<DashboardData>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? _getDefaultDashboardData();
        final profit = data.pendapatan - data.biayaOperasional;
        
        return FadeTransition(
          opacity: _contentAnimationController,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple.shade400, Colors.purple.shade600],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Ringkasan Keuangan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.purple.shade400,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFinancialRowAnimated(
                  'Penjualan',
                  data.pendapatan,
                  Colors.green.shade600,
                  Icons.trending_up,
                ),
                const SizedBox(height: 12),
                _buildFinancialRowAnimated(
                  'Pengeluaran',
                  data.biayaOperasional,
                  Colors.red.shade600,
                  Icons.trending_down,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade50,
                        Colors.purple.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROFIT BERSIH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'Rp ${NumberFormat('#,##0', 'id_ID').format(profit)}',
                              key: ValueKey(profit),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.purple.shade400],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.attach_money,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinancialRowAnimated(String label, double amount, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(amount)}',
            key: ValueKey(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _ActionItem('Restock', Icons.inventory_2_rounded, [Colors.blue.shade400, Colors.blue.shade600]),
      _ActionItem('Return', Icons.assignment_return_rounded, [Colors.orange.shade400, Colors.orange.shade600]),
      _ActionItem('Produk', Icons.category_rounded, [Colors.green.shade400, Colors.green.shade600]),
      _ActionItem('Pelanggan', Icons.people_alt_rounded, [Colors.purple.shade400, Colors.purple.shade600]),
      _ActionItem('Operasional', Icons.settings_rounded, [Colors.red.shade400, Colors.red.shade600]),
      _ActionItem('Laporan', Icons.analytics_rounded, [Colors.indigo.shade400, Colors.indigo.shade600]),
    ];

    return FadeTransition(
      opacity: _contentAnimationController,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: actions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => _buildActionButton(actions[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(_ActionItem action) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: action.colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: action.colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleActionTap(action.title),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                action.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleActionTap(String title) async {
    // Navigate dan tunggu result untuk refresh data
    bool? shouldRefresh;
    
    switch (title) {
      case 'Restock':
        shouldRefresh = await Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const RestockScreen()),
        );
        break;
      case 'Return':
        shouldRefresh = await Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const ReturnBarangScreen()),
        );
        break;
      case 'Produk':
        shouldRefresh = await Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const ManajemenBarangScreen()),
        );
        break;
      case 'Pelanggan':
        shouldRefresh = await Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const PelangganListScreen()),
        );
        break;
      case 'Operasional':
        shouldRefresh = await Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const OperasionalScreen()),
        );
        break;
      case 'Laporan':
        shouldRefresh = await Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const RekapitulasiScreen()),
        );
        break;
    }
    
    // Refresh data jika ada perubahan
    if (shouldRefresh == true && mounted) {
      _loadData();
      _contentAnimationController.forward(from: 0);
    }
  }

  Widget _buildRecentActivity() {
    return FutureBuilder<List<Transaksi>>(
      future: _recentTransactionsFuture,
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? [];
        
        return FadeTransition(
          opacity: _contentAnimationController,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                
                if (transactions.isEmpty)
                  _buildEmptyState()
                else
                  Column(
                    children: transactions.take(5).map((transaction) => 
                      _buildTransactionItem(transaction)
                    ).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada aktivitas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaksi akan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaksi transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.nomerNota,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(transaction.waktuTransaksi),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(transaction.total)}',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final List<Color> colors;

  _ActionItem(this.title, this.icon, this.colors);
}
              