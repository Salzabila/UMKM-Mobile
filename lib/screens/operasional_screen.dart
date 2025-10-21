import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OperasionalScreen extends StatefulWidget {
  const OperasionalScreen({super.key});

  @override
  State<OperasionalScreen> createState() => _OperasionalScreenState();
}

class _OperasionalScreenState extends State<OperasionalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Biaya Operasional'),
        backgroundColor: cardColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondary,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Kategori'),
            Tab(text: 'Laporan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPengeluaranTab(),
          _buildKategoriTab(),
          _buildLaporanTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahPengeluaran,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pengeluaran'),
      ),
    );
  }

  // Tab 1: Pengeluaran
  Widget _buildPengeluaranTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 16),
        _buildPengeluaranList(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Pengeluaran Bulan Ini',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Rp 5.250.000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Hari Ini', 'Rp 150.000'),
              _buildSummaryItem('Minggu Ini', 'Rp 850.000'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPengeluaranList() {
    final dummyData = [
      {
        'kategori': 'Listrik',
        'jumlah': 500000,
        'tanggal': DateTime.now(),
        'keterangan': 'Pembayaran listrik bulan Oktober',
        'color': warningColor,
        'icon': Icons.electric_bolt,
      },
      {
        'kategori': 'Gaji Karyawan',
        'jumlah': 3000000,
        'tanggal': DateTime.now().subtract(const Duration(days: 1)),
        'keterangan': 'Gaji bulan Oktober',
        'color': successColor,
        'icon': Icons.people,
      },
      {
        'kategori': 'Bahan Baku',
        'jumlah': 1500000,
        'tanggal': DateTime.now().subtract(const Duration(days: 2)),
        'keterangan': 'Pembelian stok bahan baku',
        'color': primaryColor,
        'icon': Icons.inventory,
      },
      {
        'kategori': 'Transportasi',
        'jumlah': 250000,
        'tanggal': DateTime.now().subtract(const Duration(days: 3)),
        'keterangan': 'Bensin dan tol pengiriman',
        'color': errorColor,
        'icon': Icons.local_shipping,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Pengeluaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...dummyData.map((data) => _buildPengeluaranItem(data)),
      ],
    );
  }

  Widget _buildPengeluaranItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (data['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data['icon'] as IconData,
              color: data['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['kategori'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['keterangan'] as String,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(data['tanggal'] as DateTime),
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(data['jumlah'])}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: errorColor,
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: Kategori
  Widget _buildKategoriTab() {
    final categories = [
      {'name': 'Listrik', 'icon': Icons.electric_bolt, 'color': warningColor, 'total': 500000},
      {'name': 'Gaji Karyawan', 'icon': Icons.people, 'color': successColor, 'total': 3000000},
      {'name': 'Bahan Baku', 'icon': Icons.inventory, 'color': primaryColor, 'total': 1500000},
      {'name': 'Transportasi', 'icon': Icons.local_shipping, 'color': errorColor, 'total': 250000},
      {'name': 'Sewa', 'icon': Icons.home, 'color': const Color(0xFF8B5CF6), 'total': 0},
      {'name': 'Lainnya', 'icon': Icons.more_horiz, 'color': textSecondary, 'total': 0},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Kategori Pengeluaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...categories.map((cat) => _buildKategoriItem(cat)),
      ],
    );
  }

  Widget _buildKategoriItem(Map<String, dynamic> cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (cat['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              cat['icon'] as IconData,
              color: cat['color'] as Color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              cat['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(cat['total'])}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: Laporan
  Widget _buildLaporanTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildLaporanCard(
          'Laporan Bulanan',
          'Oktober 2025',
          'Rp 5.250.000',
          Icons.calendar_month,
          primaryColor,
        ),
        const SizedBox(height: 12),
        _buildLaporanCard(
          'Laporan Tahunan',
          '2025',
          'Rp 52.500.000',
          Icons.calendar_today,
          successColor,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur export laporan dalam pengembangan')),
            );
          },
          icon: const Icon(Icons.download),
          label: const Text('Export Laporan PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLaporanCard(String title, String period, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  period,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _tambahPengeluaran() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTambahPengeluaranForm(),
    );
  }

  Widget _buildTambahPengeluaranForm() {
    final jumlahController = TextEditingController();
    final keteranganController = TextEditingController();
    String selectedCategory = 'Listrik';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Pengeluaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['Listrik', 'Gaji Karyawan', 'Bahan Baku', 'Transportasi', 'Sewa', 'Lainnya']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                selectedCategory = value ?? 'Listrik';
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keteranganController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengeluaran berhasil ditambahkan'),
                      backgroundColor: successColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}