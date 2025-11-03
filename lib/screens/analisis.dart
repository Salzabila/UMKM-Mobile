import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';
import '../service/transaksi_service.dart';

class AnalisisScreen extends StatefulWidget {
  const AnalisisScreen({super.key});

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  final TransaksiService _transaksiService = TransaksiService();
  late Future<List<Transaksi>> _transaksiFuture;
  
  String _selectedFilter = '7 Hari Terakhir';

  @override
  void initState() {
    super.initState();
    _loadTransaksi();
  }

  void _loadTransaksi() {
    setState(() {
      _transaksiFuture = _transaksiService.getRiwayatTransaksi();
    });
  }

  Map<String, double> _generateChartData(List<Transaksi> transactions) {
    if (_selectedFilter == '7 Hari Terakhir') {
      return _generateWeeklyChartData(transactions);
    } else {
      return _generateMonthlyChartData(transactions);
    }
  }

  Map<String, double> _generateWeeklyChartData(List<Transaksi> transactions) {
    final Map<String, double> dailySales = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 6));

    // Initialize 7 days
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final dayName = DateFormat('EEE').format(date); // Mon, Tue, Wed, etc
      dailySales[dayName] = 0.0;
    }

    // Fill with actual data
    for (var tx in transactions) {
      if (tx.waktuTransaksi.isAfter(startDate.subtract(const Duration(seconds: 1)))) {
        final dayName = DateFormat('EEE').format(tx.waktuTransaksi);
        dailySales[dayName] = (dailySales[dayName] ?? 0.0) + tx.total;
      }
    }

    return dailySales;
  }

  Map<String, double> _generateMonthlyChartData(List<Transaksi> transactions) {
    final Map<String, double> weeklySales = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Define 4 weeks for the month
    final weeks = ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'];
    for (String week in weeks) {
      weeklySales[week] = 0.0;
    }

    // Calculate start date (30 days ago)
    final startDate = today.subtract(const Duration(days: 29));

    // Group transactions by week
    for (var tx in transactions) {
      if (tx.waktuTransaksi.isAfter(startDate.subtract(const Duration(seconds: 1)))) {
        final daysDiff = tx.waktuTransaksi.difference(startDate).inDays;
        final weekIndex = (daysDiff ~/ 7).clamp(0, 3); // 0-3 for 4 weeks
        weeklySales[weeks[weekIndex]] = (weeklySales[weeks[weekIndex]] ?? 0.0) + tx.total;
      }
    }

    return weeklySales;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Analisis Pendapatan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadTransaksi(),
        color: const Color(0xFF3B82F6),
        child: FutureBuilder<List<Transaksi>>(
          future: _transaksiFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            if (snapshot.hasError) {
              return _buildErrorState();
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final chartData = _generateChartData(snapshot.data!);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Filter Section
                  _buildFilterSection(),
                  const SizedBox(height: 20),
                  
                  // Chart Section
                  _buildChartSection(chartData),
                  const SizedBox(height: 20),
                  
                  // Statistics Section
                  _buildStatisticsSection(snapshot.data!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFilterTab('7 Hari Terakhir'),
          _buildFilterTab('30 Hari Terakhir'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedFilter = label;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(Map<String, double> chartData) {
    final maxValue = chartData.values.isNotEmpty 
        ? chartData.values.reduce((a, b) => a > b ? a : b) 
        : 100000;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grafik Pendapatan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Periode: $_selectedFilter',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart Bars
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.entries.map((entry) {
                final label = entry.key;
                final amount = entry.value;
                final percentage = maxValue > 0 ? (amount / maxValue) : 0;
                final barHeight = percentage * 150;

                return Expanded(
                  child: Column(
                    children: [
                      // Value above bar
                      Text(
                        amount > 0 ? 'Rp ${NumberFormat('#,##0', 'id_ID').format(amount)}' : '',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      
                      // Bar
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: barHeight.toDouble(),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Label (Day for weekly, Week for monthly)
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: _selectedFilter == '7 Hari Terakhir' ? 12 : 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Chart Legend
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedFilter == '7 Hari Terakhir' 
                      ? 'Menampilkan data harian' 
                      : 'Menampilkan data mingguan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(List<Transaksi> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = _selectedFilter == '7 Hari Terakhir' 
        ? today.subtract(const Duration(days: 6))
        : today.subtract(const Duration(days: 29));

    final filteredTransactions = transactions.where((tx) => 
        tx.waktuTransaksi.isAfter(startDate.subtract(const Duration(seconds: 1)))
    ).toList();

    final totalPendapatan = filteredTransactions.fold<double>(0, (sum, tx) => sum + tx.total);
    final rataRataHarian = totalPendapatan / (_selectedFilter == '7 Hari Terakhir' ? 7 : 30);
    final transaksiCount = filteredTransactions.length;

    // Calculate additional stats for monthly view
    final rataRataMingguan = _selectedFilter == '30 Hari Terakhir' 
        ? totalPendapatan / 4 
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Title
          Row(
            children: [
              Icon(Icons.analytics, size: 20, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                _selectedFilter == '7 Hari Terakhir' 
                    ? 'Statistik 7 Hari' 
                    : 'Statistik 30 Hari',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Statistics Grid - Adapt based on filter
          if (_selectedFilter == '7 Hari Terakhir') ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Pendapatan',
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(totalPendapatan)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Rata-rata Harian',
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(rataRataHarian)}',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              'Total Transaksi',
              '$transaksiCount Transaksi',
              Icons.receipt,
              Colors.purple,
              fullWidth: true,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Pendapatan',
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(totalPendapatan)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Rata-rata Mingguan',
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(rataRataMingguan)}',
                    Icons.calendar_view_week,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Rata-rata Harian',
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(rataRataHarian)}',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Total Transaksi',
                    '$transaksiCount Transaksi',
                    Icons.receipt,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
          const SizedBox(height: 16),
          const Text(
            'Memuat analisis...',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan coba lagi',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransaksi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Data Analisis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaksi akan muncul di sini setelah ada penjualan',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}