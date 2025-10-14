import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/keranjang.dart';
import '../models/transaksi.dart';
import '../service/barang_service.dart';
import '../service/keranjang_provider.dart';
import '../service/transaksi_service.dart';
import './transaksi_berhasil_screen.dart';
import './pembayaran_qris.dart';
import './pembayaran_kartu.dart';
import './pembayaran_transfer.dart';

class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({super.key});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  final _uangDiterimaController = TextEditingController();
  String _selectedPaymentMethod = 'Tunai';

  // Simplified Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'Tunai',
      'name': 'Tunai',
      'icon': Icons.payments,
      'color': successColor,
    },
    {
      'id': 'QRIS',
      'name': 'QRIS',
      'icon': Icons.qr_code_2,
      'color': primaryColor,
    },
    {
      'id': 'Debit',
      'name': 'Kartu Debit',
      'icon': Icons.credit_card,
      'color': const Color(0xFF06D6A0),
    },
    {
      'id': 'Transfer',
      'name': 'Transfer Bank',
      'icon': Icons.account_balance,
      'color': const Color(0xFF3B82F6),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keranjang = Provider.of<KeranjangProvider>(context, listen: false);
      _selectedPaymentMethod = keranjang.metodePembayaran.isNotEmpty 
          ? keranjang.metodePembayaran 
          : 'Tunai';
      _uangDiterimaController.text = keranjang.totalHarga.toStringAsFixed(0);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _uangDiterimaController.dispose();
    super.dispose();
  }

  void _prosesPembayaran() {
    final keranjang = Provider.of<KeranjangProvider>(context, listen: false);
    
    switch (_selectedPaymentMethod) {
      case 'QRIS':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PembayaranQrisScreen(totalAmount: keranjang.totalHarga)
        ));
        break;
      case 'Debit':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PembayaranKartuScreen(totalAmount: keranjang.totalHarga)
        ));
        break;
      case 'Transfer':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PembayaranTransferScreen(totalAmount: keranjang.totalHarga)
        ));
        break;
      case 'Tunai':
      default:
        _showDialogKonfirmasiTunai();
        break;
    }
  }

  void _showDialogKonfirmasiTunai() async {
    final keranjang = Provider.of<KeranjangProvider>(context, listen: false);
    final transaksiService = TransaksiService();
    final barangService = BarangService();
    final double uangDiterima = double.tryParse(_uangDiterimaController.text) ?? 0.0;

    if (uangDiterima < keranjang.totalHarga) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang yang diterima kurang!'),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final namaPetugas = prefs.getString('loggedInUsername') ?? 'Kasir';
    final currentContext = context;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildConfirmRow('Total', keranjang.totalHarga),
            const Divider(),
            _buildConfirmRow('Uang Diterima', uangDiterima),
            const Divider(),
            _buildConfirmRow('Kembalian', uangDiterima - keranjang.totalHarga),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Simpan barang kustom
              for (var item in keranjang.items.values) {
                if (item.barang.id.startsWith('kustom-')) {
                  await barangService.addBarang(item.barang);
                }
              }

              // Buat transaksi
              final transaksiBaru = Transaksi(
                id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
                nomerNota: 'INV/${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                waktuTransaksi: DateTime.now(),
                petugas: namaPetugas,
                metodeBayar: _selectedPaymentMethod,
                status: 'Sukses',
                items: List<KeranjangItem>.from(keranjang.items.values),
                total: keranjang.totalHarga,
                uangDiterima: uangDiterima,
                kembalian: uangDiterima - keranjang.totalHarga,
                pelangganId: keranjang.pelanggan?.id,
                pelangganNama: keranjang.pelanggan?.namaLengkap,
              );

              await transaksiService.simpanTransaksi(transaksiBaru);
              keranjang.bersihkanKeranjang();

              if (mounted) {
                Navigator.of(ctx).pop();
                Navigator.of(currentContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => TransaksiBerhasilScreen(transaksi: transaksiBaru)
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: successColor),
            child: const Text('Proses'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(amount)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: cardColor,
        elevation: 0,
      ),
      body: Consumer<KeranjangProvider>(
        builder: (context, keranjang, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Tagihan',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${NumberFormat('#,##0', 'id_ID').format(keranjang.totalHarga)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${keranjang.jumlahItem} Item',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Methods
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                ..._paymentMethods.map((method) {
                  final isSelected = _selectedPaymentMethod == method['id'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? method['color'] : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        method['icon'],
                        color: method['color'],
                      ),
                      title: Text(
                        method['name'],
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: method['color'])
                          : const Icon(Icons.circle_outlined, color: Colors.grey),
                      onTap: () {
                        setState(() {
                          _selectedPaymentMethod = method['id'];
                        });
                      },
                    ),
                  );
                }),

                if (_selectedPaymentMethod == 'Tunai') ...[
                  const SizedBox(height: 24),
                  
                  // Cash Input
                  const Text(
                    'Uang Diterima',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _uangDiterimaController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      hintText: '0',
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Quick Amount Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [20000, 50000, 100000, 200000].map((nominal) {
                      return OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _uangDiterimaController.text = nominal.toString();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: successColor),
                        ),
                        child: Text('${nominal ~/ 1000}k'),
                      );
                    }).toList(),
                  ),
                  
                  // Kembalian
                  if (_uangDiterimaController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: successColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kembalian',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: successColor,
                            ),
                          ),
                          Text(
                            'Rp ${NumberFormat('#,##0', 'id_ID').format((double.tryParse(_uangDiterimaController.text) ?? 0) - keranjang.totalHarga)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _prosesPembayaran,
            style: ElevatedButton.styleFrom(
              backgroundColor: successColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Proses Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}