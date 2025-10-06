import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/keranjang.dart';
import '../models/transaksi.dart';
import '../service/barang_service.dart';
import '../service/keranjang_provider.dart';
import '../service/transaksi_service.dart';
import '../widgets/preview_struk.dart';
import './transaksi_berhasil_screen.dart';
import './pembayaran_qris.dart';
import './pembayaran_kartu.dart';
import './pembayaran_transfer.dart';

class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({super.key});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> 
    with SingleTickerProviderStateMixin {
  final _uangDiterimaController = TextEditingController();
  late AnimationController _animationController;
  String _selectedPaymentMethod = 'Tunai';
  
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'Tunai',
      'name': 'Tunai',
      'subtitle': 'Bayar dengan uang cash',
      'icon': Icons.payments_rounded,
      'colors': [Colors.green, Colors.green],
    },
    {
      'id': 'QRIS',
      'name': 'QRIS',
      'subtitle': 'Scan QR untuk bayar',
      'icon': Icons.qr_code_scanner_rounded,
      'colors': [Colors.blue, Colors.blue],
    },
    {
      'id': 'Debit',
      'name': 'Kartu Debit',
      'subtitle': 'Bayar dengan kartu debit',
      'icon': Icons.credit_card_rounded,
      'colors': [Colors.purple, Colors.purple],
    },
    {
      'id': 'Transfer',
      'name': 'Transfer Bank',
      'subtitle': 'Transfer ke rekening',
      'icon': Icons.account_balance_rounded,
      'colors': [Colors.orange, Colors.orange],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
    
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
    _animationController.dispose();
    super.dispose();
  }

  void _prosesPembayaran() {
    final keranjang = Provider.of<KeranjangProvider>(context, listen: false);
    
    switch (_selectedPaymentMethod) {
      case 'QRIS':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PembayaranQrisScreen(
              totalAmount: keranjang.totalHarga,
            )
          )
        );
        break;
      case 'Debit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PembayaranKartuScreen(
              totalAmount: keranjang.totalHarga,
            )
          )
        );
        break;
      case 'Transfer':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PembayaranTransferScreen(
              totalAmount: keranjang.totalHarga,
            )
          )
        );
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
      _showErrorSnackbar('Uang yang diterima kurang dari total tagihan!');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final namaPetugas = prefs.getString('loggedInUsername') ?? 'Kasir';

    // PERBAIKAN: Simpan context sebelum async operation
    final currentContext = context;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.help_outline, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text('Konfirmasi Pembayaran', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pastikan nominal pembayaran sudah benar:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildConfirmationRow('Total', keranjang.totalHarga),
            _buildConfirmationRow('Uang Diterima', uangDiterima),
            _buildConfirmationRow('Kembalian', uangDiterima - keranjang.totalHarga),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              for (var item in keranjang.items.values) {
                if (item.barang.id.startsWith('kustom-')) {
                  await barangService.addBarang(item.barang);
                }
              }

              final transaksiBaru = Transaksi(
                id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
                nomerNota: 'INV/${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
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

              // PERBAIKAN: Gunakan context yang disimpan
              if (mounted) {
                Navigator.of(ctx).pop();
                Navigator.of(currentContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => TransaksiBerhasilScreen(transaksi: transaksiBaru)
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Proses', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: label == 'Kembalian' ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildModernAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalCard(),
                    const SizedBox(height: 24),
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    _buildPaymentMethodSection(),
                    const SizedBox(height: 24),
                    if (_selectedPaymentMethod == 'Tunai')
                      _buildCashInputSection(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.blue),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pembayaran',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pilih metode pembayaran',
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.payment_rounded,
                color: Colors.blue,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Consumer<KeranjangProvider>(
      builder: (context, keranjang, _) {
        return FadeTransition(
          opacity: _animationController,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.blue,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'TOTAL TAGIHAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Rp ${NumberFormat('#,##0', 'id_ID').format(keranjang.totalHarga)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${keranjang.jumlahItem} Item',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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

  Widget _buildOrderSummary() {
    return Consumer<KeranjangProvider>(
      builder: (context, keranjang, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
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
                  const Text(
                    'Ringkasan Pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => PreviewStruk(keranjang: keranjang),
                      );
                    },
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Detail'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...keranjang.items.values.take(3).map((item) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.purple.shade400],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.barang.namaBarang,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${item.kuantitas}x',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${NumberFormat('#,##0', 'id_ID').format(item.barang.harga * item.kuantitas)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (keranjang.items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ${keranjang.items.length - 3} item lainnya',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._paymentMethods.map((method) {
          final isSelected = _selectedPaymentMethod == method['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPaymentMethodCard(method, isSelected),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    Map<String, dynamic> method,
    bool isSelected,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? method['colors'][0] : Colors.grey.shade200,
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: method['colors'][0].withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method['id'];
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: method['colors']),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(method['icon'], color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? method['colors'][1] : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        method['subtitle'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? method['colors'][0] : Colors.grey.shade300,
                      width: 2,
                    ),
                    gradient: isSelected
                        ? LinearGradient(colors: method['colors'])
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCashInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
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
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Uang Diterima',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _uangDiterimaController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
              hintText: '0',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Consumer<KeranjangProvider>(
            builder: (context, keranjang, _) {
              final uangDiterima = double.tryParse(_uangDiterimaController.text) ?? 0.0;
              final kembalian = uangDiterima - keranjang.totalHarga;
              
              if (uangDiterima > 0) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kembalian >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kembalian',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kembalian >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        'Rp ${NumberFormat('#,##0', 'id_ID').format(kembalian.abs())}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kembalian >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _prosesPembayaran,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Proses Pembayaran',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
}