import 'package:flutter/material.dart'; 
import 'package:intl/intl.dart'; 
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/rekap_data.dart';
import '../service/rekapitulasi_service.dart';
import '../utils/enums.dart';

class RekapitulasiScreen extends StatefulWidget {
  const RekapitulasiScreen({super.key});

  @override
  State<RekapitulasiScreen> createState() => _RekapitulasiScreenState();
}

class _RekapitulasiScreenState extends State<RekapitulasiScreen> 
    with SingleTickerProviderStateMixin {
  final RekapitulasiService _rekapService = RekapitulasiService();
  Future<RekapData>? _rekapFuture;
  PeriodeWaktu _selectedPeriode = PeriodeWaktu.hariIni;
  late AnimationController _animationController;
  int _currentTab = 0;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _rekapFuture = _rekapService.getRekapData(_selectedPeriode);
    });
  }

  // Fungsi untuk export ke CSV (Excel) - TANPA PACKAGE CSV
  Future<void> _exportToCSV(RekapData data) async {
    setState(() {
      _isExporting = true;
    });

    try {
      StringBuffer csv = StringBuffer();

      // Header
      csv.writeln('LAPORAN KEUANGAN');
      csv.writeln('Periode,${_getPeriodeText()}');
      csv.writeln('Tanggal Export,${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      csv.writeln();

      // Ringkasan Keuangan
      csv.writeln('RINGKASAN KEUANGAN');
      csv.writeln('Pendapatan,Rp ${NumberFormat('#,##0', 'id_ID').format(data.totalPendapatan)}');
      csv.writeln('Pengeluaran,Rp ${NumberFormat('#,##0', 'id_ID').format(data.totalPengeluaran)}');
      csv.writeln('Laba Bersih,Rp ${NumberFormat('#,##0', 'id_ID').format(data.labaBersih)}');
      csv.writeln();

      // Analisis Profit/Loss
      final percentage = data.totalPendapatan > 0 
          ? (data.labaBersih / data.totalPendapatan * 100).abs() 
          : 0;
      csv.writeln('ANALISIS PROFIT/LOSS');
      csv.writeln('${data.labaBersih >= 0 ? 'PROFIT' : 'LOSS'},Rp ${NumberFormat('#,##0', 'id_ID').format(data.labaBersih.abs())}');
      csv.writeln('Persentase,${percentage.toStringAsFixed(1)}%');
      csv.writeln();

      // Statistik Cepat
      csv.writeln('STATISTIK CEPAT');
      final totalTransaksi = data.daftarTransaksi.length;
      final totalPengeluaranItems = data.daftarPengeluaran.length;
      final rataRataTransaksi = totalTransaksi > 0 
          ? data.totalPendapatan / totalTransaksi 
          : 0;
      final marginPercentage = data.totalPendapatan > 0 
          ? (data.labaBersih / data.totalPendapatan * 100) 
          : 0;
      
      csv.writeln('Total Transaksi,$totalTransaksi');
      csv.writeln('Items Pengeluaran,$totalPengeluaranItems');
      csv.writeln('Rata-rata per Transaksi,Rp ${NumberFormat('#,##0', 'id_ID').format(rataRataTransaksi.round())}');
      csv.writeln('Margin,${marginPercentage.toStringAsFixed(1)}%');
      csv.writeln();

      // Data Pendapatan
      csv.writeln('DATA PENDAPATAN');
      csv.writeln('No. Nota,Tanggal,Waktu,Total (Rp)');
      for (var transaksi in data.daftarTransaksi) {
        csv.writeln('"${transaksi.nomerNota ?? '-'}",${DateFormat('dd/MM/yyyy').format(transaksi.waktuTransaksi)},${DateFormat('HH:mm').format(transaksi.waktuTransaksi)},${NumberFormat('#,##0', 'id_ID').format(transaksi.total)}');
      }
      csv.writeln();

      // Data Pengeluaran
      csv.writeln('DATA PENGELUARAN');
      csv.writeln('Nama Biaya,Tanggal,Jumlah (Rp)');
      for (var pengeluaran in data.daftarPengeluaran) {
        csv.writeln('"${pengeluaran.namaBiaya ?? 'Biaya Operasional'}",${DateFormat('dd/MM/yyyy').format(pengeluaran.tanggal)},${NumberFormat('#,##0', 'id_ID').format(pengeluaran.jumlah)}');
      }

      // Save file
      final String path = (await getTemporaryDirectory()).path;
      final String fileName = '$path/Laporan_Keuangan_${_getFileName()}.csv';
      final File file = File(fileName);
      await file.writeAsString(csv.toString());
      
      // Share file - PERBAIKI DEPRECATED METHOD
      await Share.shareXFiles([XFile(fileName)], text: 'Laporan Keuangan ${_getPeriodeText()}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan CSV berhasil diexport'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error export CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  // Fungsi untuk export ke PDF (menggunakan share text sebagai alternatif)
  Future<void> _exportToPDF(RekapData data) async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Build text report
      StringBuffer report = StringBuffer();
      
      report.writeln('LAPORAN KEUANGAN');
      report.writeln('Periode: ${_getPeriodeText()}');
      report.writeln('Tanggal Export: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      report.writeln();
      
      // Ringkasan Keuangan
      report.writeln('RINGKASAN KEUANGAN');
      report.writeln('Pendapatan: Rp ${NumberFormat('#,##0', 'id_ID').format(data.totalPendapatan)}');
      report.writeln('Pengeluaran: Rp ${NumberFormat('#,##0', 'id_ID').format(data.totalPengeluaran)}');
      report.writeln('Laba Bersih: Rp ${NumberFormat('#,##0', 'id_ID').format(data.labaBersih)}');
      report.writeln();
      
      // Analisis Profit/Loss
      final percentage = data.totalPendapatan > 0 
          ? (data.labaBersih / data.totalPendapatan * 100).abs() 
          : 0;
      report.writeln('ANALISIS PROFIT/LOSS');
      report.writeln('${data.labaBersih >= 0 ? 'PROFIT' : 'LOSS'}: Rp ${NumberFormat('#,##0', 'id_ID').format(data.labaBersih.abs())}');
      report.writeln('Persentase: ${percentage.toStringAsFixed(1)}% dari pendapatan');
      report.writeln();
      
      // Statistik Cepat
      report.writeln('STATISTIK CEPAT');
      final totalTransaksi = data.daftarTransaksi.length;
      final totalPengeluaranItems = data.daftarPengeluaran.length;
      final rataRataTransaksi = totalTransaksi > 0 
          ? data.totalPendapatan / totalTransaksi 
          : 0;
      final marginPercentage = data.totalPendapatan > 0 
          ? (data.labaBersih / data.totalPendapatan * 100) 
          : 0;
      
      report.writeln('Total Transaksi: $totalTransaksi');
      report.writeln('Items Pengeluaran: $totalPengeluaranItems');
      report.writeln('Rata-rata per Transaksi: Rp ${NumberFormat('#,##0', 'id_ID').format(rataRataTransaksi.round())}');
      report.writeln('Margin: ${marginPercentage.toStringAsFixed(1)}%');
      report.writeln();
      
      // Data Pendapatan
      report.writeln('DATA PENDAPATAN (${data.daftarTransaksi.length} items)');
      for (var transaksi in data.daftarTransaksi) {
        report.writeln('- ${transaksi.nomerNota ?? '-'} | ${DateFormat('dd/MM/yyyy HH:mm').format(transaksi.waktuTransaksi)} | Rp ${NumberFormat('#,##0', 'id_ID').format(transaksi.total)}');
      }
      report.writeln();
      
      // Data Pengeluaran
      report.writeln('DATA PENGELUARAN (${data.daftarPengeluaran.length} items)');
      for (var pengeluaran in data.daftarPengeluaran) {
        report.writeln('- ${pengeluaran.namaBiaya ?? 'Biaya Operasional'} | ${DateFormat('dd/MM/yyyy').format(pengeluaran.tanggal)} | Rp ${NumberFormat('#,##0', 'id_ID').format(pengeluaran.jumlah)}');
      }

      // Share as text (alternatif PDF) - PERBAIKI DEPRECATED METHOD
      await Share.share(report.toString(), subject: 'Laporan Keuangan ${_getPeriodeText()}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil diexport'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _getPeriodeText() {
    switch (_selectedPeriode) {
      case PeriodeWaktu.hariIni:
        return 'Hari Ini';
      case PeriodeWaktu.mingguIni:
        return 'Minggu Ini';
      case PeriodeWaktu.bulanIni:
        return 'Bulan Ini';
      case PeriodeWaktu.tahunIni:
        return 'Tahun Ini';
      default:
        return 'Hari Ini';
    }
  }

  String _getFileName() {
    final now = DateTime.now();
    final periode = _getPeriodeText().toLowerCase().replaceAll(' ', '_');
    return '${DateFormat('yyyyMMdd_HHmmss').format(now)}_$periode';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildModernHeader()),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildPeriodeFilter(),
                  const SizedBox(height: 24),
                  _buildTabNavigation(),
                  const SizedBox(height: 24),
                  FutureBuilder<RekapData>(
                    future: _rekapFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingState();
                      }
                      if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      }
                      if (!snapshot.hasData) {
                        return _buildEmptyState();
                      }
                      
                      final data = snapshot.data!;
                      return _buildContent(data);
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildModernHeader() sampai _buildEmptyListState() 
  // TIDAK DIUBAH - sama seperti kode sebelumnya

  Widget _buildModernHeader() {
    return FadeTransition(
      opacity: _animationController,
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
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekapitulasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Analisis keuangan lengkap',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
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
          final isSelected = _selectedPeriode == filter.$2;
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
                      _selectedPeriode = filter.$2;
                    });
                    _loadData();
                    _animationController.forward(from: 0);
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

  Widget _buildTabNavigation() {
    final tabs = ['Ringkasan', 'Pendapatan', 'Pengeluaran'];
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = _currentTab == index;
          
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Colors.blue.shade500, Colors.blue.shade600],
                      )
                    : null,
                color: isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _currentTab = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
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

  Widget _buildContent(RekapData data) {
    switch (_currentTab) {
      case 0:
        return _buildSummaryTab(data);
      case 1:
        return _buildIncomeTab(data);
      case 2:
        return _buildExpenseTab(data);
      default:
        return _buildSummaryTab(data);
    }
  }

  Widget _buildSummaryTab(RekapData data) {
    return Column(
      children: [
        _buildFinancialOverview(data),
        const SizedBox(height: 24),
        _buildProfitLossAnalysis(data),
        const SizedBox(height: 24),
        _buildQuickStats(data),
        const SizedBox(height: 24),
        _buildExportButtons(data),
      ],
    );
  }

  Widget _buildFinancialOverview(RekapData data) {
    return Container(
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
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Ringkasan Keuangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFinancialItem('Pendapatan', data.totalPendapatan, Colors.green),
          const SizedBox(height: 16),
          _buildFinancialItem('Pengeluaran', data.totalPengeluaran, Colors.red),
          const SizedBox(height: 16),
          _buildFinancialItem('Laba Bersih', data.labaBersih, 
              data.labaBersih >= 0 ? Colors.blue : Colors.orange),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFinancialIcon(title),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rp ${NumberFormat('#,##0', 'id_ID').format(value.abs())}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFinancialIcon(String title) {
    switch (title) {
      case 'Pendapatan':
        return Icons.arrow_downward_rounded;
      case 'Pengeluaran':
        return Icons.arrow_upward_rounded;
      case 'Laba Bersih':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.money_rounded;
    }
  }

  Widget _buildProfitLossAnalysis(RekapData data) {
    final profit = data.labaBersih;
    final isProfit = profit >= 0;
    final percentage = data.totalPendapatan > 0 
        ? (profit / data.totalPendapatan * 100).abs() 
        : 0;

    return Container(
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
          const Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Analisis Profit/Loss',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Loss/Profit Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isProfit ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isProfit ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Column(
              children: [
                Text(
                  isProfit ? 'PROFIT' : 'LOSS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isProfit ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${NumberFormat('#,##0', 'id_ID').format(profit.abs())}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${percentage.toStringAsFixed(1)}% dari pendapatan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Income and Expense details
          Row(
            children: [
              Expanded(
                child: _buildAnalysisDetail(
                  'Pendapatan',
                  data.totalPendapatan,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalysisDetail(
                  'Pengeluaran',
                  data.totalPengeluaran,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisDetail(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(value)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(RekapData data) {
    // Hitung statistik yang benar
    final totalTransaksi = data.daftarTransaksi.length;
    final totalPengeluaranItems = data.daftarPengeluaran.length;
    final rataRataTransaksi = totalTransaksi > 0 
        ? data.totalPendapatan / totalTransaksi 
        : 0;
    final marginPercentage = data.totalPendapatan > 0 
        ? (data.labaBersih / data.totalPendapatan * 100) 
        : 0;

    return Container(
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
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Statistik Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Layout menggunakan GridView dengan constraints yang tepat
          GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _buildFixedHeightStatItem(
                'Total\nTransaksi',
                totalTransaksi.toString(),
                Icons.receipt_long,
                Colors.blue,
              ),
              _buildFixedHeightStatItem(
                'Items\nPengeluaran',
                totalPengeluaranItems.toString(),
                Icons.list_alt,
                Colors.orange,
              ),
              _buildFixedHeightStatItem(
                'Rata-rata',
                'Rp ${NumberFormat('#,##0', 'id_ID').format(rataRataTransaksi.round())}',
                Icons.attach_money,
                Colors.green,
              ),
              _buildFixedHeightStatItem(
                'Margin',
                '${marginPercentage.toStringAsFixed(1)}%',
                Icons.trending_up,
                marginPercentage >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFixedHeightStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian title dengan icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bagian value
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons(RekapData data) {
    return Column(
      children: [
        if (_isExporting)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
        Row(
          children: [
            Expanded(
              child: _buildExportButton(
                'Export CSV',
                Icons.table_chart,
                Colors.green,
                () => _exportToCSV(data),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExportButton(
                'Export Laporan',
                Icons.description,
                Colors.blue,
                () => _exportToPDF(data),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isExporting ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeTab(RekapData data) {
    return Column(
      children: [
        _buildTransactionList(data.daftarTransaksi, 'Pendapatan', Colors.green),
        const SizedBox(height: 24),
        _buildExportButtons(data),
      ],
    );
  }

  Widget _buildExpenseTab(RekapData data) {
    return Column(
      children: [
        _buildExpenseList(data.daftarPengeluaran),
        const SizedBox(height: 24),
        _buildExportButtons(data),
      ],
    );
  }

  Widget _buildTransactionList(List<dynamic> transactions, String title, Color color) {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$title (${transactions.length} items)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (transactions.isEmpty)
            _buildEmptyListState('Tidak ada data $title')
          else
            Column(
              children: transactions.take(10).map((item) => 
                _buildTransactionItem(item, color)
              ).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<dynamic> expenses) {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Pengeluaran (${expenses.length} items)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (expenses.isEmpty)
            _buildEmptyListState('Tidak ada data pengeluaran')
          else
            Column(
              children: expenses.map((expense) => 
                _buildExpenseItem(expense)
              ).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(dynamic transaction, Color color) {
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.nomerNota ?? 'No Reference',
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
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(dynamic expense) {
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
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.namaBiaya ?? 'Biaya Operasional',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(expense.tanggal),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(expense.jumlah)}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Tidak ada data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Data rekapitulasi akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyListState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.list_alt_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}